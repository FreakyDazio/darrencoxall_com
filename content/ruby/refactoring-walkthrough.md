---
date: 2014-12-24T09:43:51Z
draft: true
title: "Refactoring Walkthrough"
type: post
---

Refactoring is the process of restructuring, re-architecting and modifying
existing code without affecting the output of the code. The aim is to reduce
complexity simultaneously improving the ability to modify the code at a later
date. I want to walk you through my own refactoring process with a real world
example.

We will be refactoring [shtirlic/sinatra-jsonp][jsonp-github]. This is a small
sinatra extension that adds support for older browsers when returning json as
it provides callback function support. I have selected this as I have used it in
a project and I know that the main bulk of the functionality is implemented in
a rather complex method making it a prime candidate for refactoring.

So to begin with I am going to fork the repository so my starting point is
[`7436fd1fa3`][start]. If I now clone this locally I can start setting up my
baselines and checking the tests.

_Tests are perhaps the single most important thing to have in place when
refactoring. Without them it is extremely difficult to assert that the code is
producing the same results both before and after the refactoring._

    $ git clone git@github.com:dcoxall/sinatra-jsonp.git
    $ cd sinatra-jsonp
    $ bundle install
    $ bundle exec rake

You will see that I installed any dependencies and then ran the default rake
task. In most ruby programs this is the standard way of running the complete
test suite. In this case it was right and all the tests passed but there were
some deprecations.

> stdlib is deprecated. Use :test_unit or :minitest instead

Now this is a good place to start. If I can fix any issues like this now I will
have a nicer environment to work with later so at this point I will create a
branch.

    $ git checkout -b refactor

With a branch created I can start making my changes. The offending line causing
the deprecation warning is in `spec/spec_helper.rb` so my first action was to
remove it and see what effect it had on the tests by running them again.

Low-and-behold everything passed but without any warnings. Awesome. So I can
commit this change.

    $ git add spec/spec_helper.rb
    $ git ci -m "Fix deprecated use of stdlib"

Now I want to introduce a tool I like to use called [rubocop][rubocop] which
can analyse ruby code to check that it follows particular conventions but more
importantly in this case it also includes metrics that report on estimated
complexity and an ABC rating (Assignments, branching and conditions) where a
higher number often indicates complex or difficult to follow code. This will
provide me a baseline and I can work on reducing these metrics providing me a
tangible target.

    $ gem install rubocop
    $ rubocop -f s --only \
    > Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity

In the above command I limit rubocop to look only for ABC rating, method length
and the perceived complexity. These will be the metrics I want to improve. The
result is the following:

    == lib/sinatra/jsonp.rb ==
    C:  6:  5: Assignment Branch Condition size for jsonp is too high. [19.34/15]
    C:  6:  5: Method has too many lines. [19/10]
    C:  6:  5: Perceived complexity for jsonp is too high. [8/7]

Now I have a starting point and passing tests. It's time to look at the code.
All the reported issues are in [`lib/sinatra/jsonp.rb`][code] which is where all
the main logic is kept.

My first instinct is to go through the method and document what it is actualy
doing. I find it much easier to re-structure the code once I understand what
functions it is serving. It is then a case of moving pieces to their own
methods.

    def jsonp(*args)
      # requires 1 or more arguments
      if args.size > 0
        # The first argument is the object to serialize
        data = MultiJson.dump(
          args[0],
          :pretty => settings.respond_to?(:json_pretty) && settings.json_pretty
        )
        # If we have another argument it is the callback function name
        if args.size > 1
          callback = args[1].to_s
        else
          # If not then determine the callback based on the following parameters
          ['callback','jscallback','jsonp','jsoncallback'].each do |x|
            callback = params.delete(x) unless callback
          end
        end
        # If we have a callback perform some basic sanitization and set the
        # response content type and the eventual response body
        if callback
          callback.tr!('^a-zA-Z0-9_$\.', '')
          content_type :js
          response = "#{callback}(#{data})"
        else
          # If no callback then set the response content type to json and return
          # the serialized data
          content_type :json
          response = data
        end
        response
      end
    end

With this view I am going to work top-down and so first is to implement a guard
condition by returning early if we have in-sufficient arguments. I then decide
that I can make the `pretty` flag into a different method.

    # requires 1 or more arguments
    return if args.size < 1

    # The first argument is the object to serialize
    data = MultiJson.dump(args[0], :pretty => display_pretty_json?)

    # ...

    private

    def display_pretty_json?
      !!(settings.respond_to?(:json_pretty) && settings.json_pretty)
    end

Now running the tests and rubocop again reveal that everything is still passing
but I have already corrected the perceived complexity of the method as well as
improved the ABC score (by 3.03).

    == lib/sinatra/jsonp.rb ==
    C:  6:  5: Assignment Branch Condition size for jsonp is too high. [16.31/15]
    C:  6:  5: Method has too many lines. [18/10]

Time to commit these changes and then tackle the callback calculation.

    $ git add lib/sinatra/jsonp.rb
    $ git commit -m "Introduce guard condition and extract setting checks"

I move the logic for determining the callback name into a new method and I also
move the list of parameter keys to check into a constant. This leaves us with
the following...

    CALLBACK_PARAMS = %w( callback jscallback jsonp jsoncallback ).freeze

    def jsonp(*args)
      return if args.size < 1

      data = MultiJson.dump(args[0], :pretty => display_pretty_json?)
      callback = extract_callback_name(args[1])

      # If we have a callback perform some basic sanitization and set the
      # response content type and the eventual response body
      if callback
        callback.tr!('^a-zA-Z0-9_$\.', '')
        content_type :js
        response = "#{callback}(#{data})"
      else
        # If no callback then set the response content type to json and return
        # the serialized data
        content_type :json
        response = data
      end
      response
    end
    alias JSONP jsonp

    private

    def display_pretty_json?
      !!(settings.respond_to?(:json_pretty) && settings.json_pretty)
    end

    def extract_callback_name(name = nil)
      if name.nil?
        callback = nil
        CALLBACK_PARAMS.each do |key|
          callback = params.delete(key) unless callback
        end
        callback ? callback.to_s : nil
      else
        name.to_s
      end
    end

Again running the tests and rubocop tell me that everything is still working
and I have now also corrected the ABC score to an acceptable level. The only
metric that rubocop is complaining about now is the method length. Once again,
it's time to commit our changes and move onto finalizing the response.

    $ git add lib/sinatra/jsonp.rb
    $ git commit -m "Callback name extraction moved to new method"

Now for this next refactor I don't want the method to have any side-effects and
so I don't want the new method to call `content_type` explicitly but instead
return both the response body and the correct content type which the main method
can use.

The result of this is shown below

    CALLBACK_PARAMS = %w( callback jscallback jsonp jsoncallback ).freeze

    def jsonp(*args)
      return if args.size < 1
      data = MultiJson.dump(args[0], :pretty => display_pretty_json?)
      callback = extract_callback_name(args[1])
      type, response = determine_response(data, callback)
      content_type(type)
      response
    end
    alias JSONP jsonp

    private

    def determine_response(data, callback = nil)
      return [:json, data] if callback.nil?
      callback.tr!('^a-zA-Z0-9_$\.', '')
      [:js, format("%s(%s)", callback, data)]
    end

    def display_pretty_json?
      !!(settings.respond_to?(:json_pretty) && settings.json_pretty)
    end

    def extract_callback_name(name = nil)
      if name.nil?
        callback = nil
        CALLBACK_PARAMS.each do |key|
          callback = params.delete(key) unless callback
        end
        callback ? callback.to_s : nil
      else
        name.to_s
      end
    end

Running the tests and rubocop now reveal all tests continue to pass and rubocop
has nothing to complain about! I can commit this and create a pull request.

I've demonstrated how I like to refactor with the aim of making the code easier
to work with. What once was a large single method is now several smaller more
succinct methods. This also provides an additional benefit in that the method
names now also document the behaviour of the code making it easier for others to
read and understand.

Thank you for reading. You can see the [final pull request here][pr]. Now go out
and improve some code!

[jsonp-github]: https://github.com/shtirlic/sinatra-jsonp
[start]: https://github.com/dcoxall/sinatra-jsonp/tree/7436fd1fa38d6654560fa3e4af52c734dd818073
[rubocop]: https://github.com/bbatsov/rubocop
[code]: https://github.com/dcoxall/sinatra-jsonp/blob/7436fd1fa38d6654560fa3e4af52c734dd818073/lib/sinatra/jsonp.rb
[pr]: https://github.com/shtirlic/sinatra-jsonp/pull/6
