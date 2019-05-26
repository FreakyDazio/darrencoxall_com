---
date: 2013-07-24T20:17:00Z
title: "Learning Ruby: Everything is an Object"
type: post
aliases:
  - /learn-ruby/everything-is-an-object/
---

The first thing to learn about Ruby is that *everything is an object*. The best way to make use of the languages features are to develop in an Object-Orientated way. This being the first article in many about learning Ruby, I will walk you through *classes* and *objects*. Ready?

If you would like to follow along make sure you install Ruby and then create a file called `learn_ruby_01.rb`.

## What is a Class?
Classes in Ruby are basically containers. They store methods that can be used and provide systems in which to store data. The main use of a class is to define something that can be created multiple times, each time with it's own unique data.

Classes can be defined like so:

```ruby
class MyFirstClass
  def hello
    puts "Hello, World!"
  end
end
```

The first line declares the class name ('MyFirstClass' in this example). Everything between this and `end` is the class definition. The definition in my example has a `hello` method indicated by the `def` (I believe it stands for define). Everything between the define and the next `end` is contained in the `hello` method.

On line 3 we call a method called `puts` with the text "Hello, World!". This line will output the text to the terminal/console window.

Putting it all together we can see that we have a class called MyFirstClass which has 1 method - `hello` - which will put "Hello, World!" in the terminal when called.

## What is an Object?
Continuing from our previous example we now create an *object* of `MyFirstExample`. To do that add the following to the bottom of our example file.

```ruby
class MyFirstClass
  def hello
    puts "Hello, World!"
  end
end

# This is a comment. Below we create an object.
object = MyFirstObject.new
object.hello
```

If you now run our file with `ruby /path/to/example.rb` you will see that it outputs "Hello, World!".

We've created our own class but Ruby provides many to begin with. In-fact we have used 3 in our example:

  1. `puts` is a method on a class called `Object` which is what amost everything in Ruby branches from.
  2. We pass text to the `puts` method but the text itself is an object of a class called `String`. Strings are just a code representation of text. Another way of showing this is `String.new("Hello, World!")`.
  3. Obviously the third is our own class - `MyFirstClass`.

Ruby has a great many classes to help us start. Below is an example of a small number available to us:

```ruby
# Numeric represents numbers
# It has many subclasses such as:
234.class # => Fixnum - integers
234.56.class # => Float - decimals

# Array represents lists of objects
[1,2,3].class # => Array
["sentence one", "sentence two"].class # => Array

# Hash represents a list of key value pairs
{ :key_name => "key value" }.class # => Hash
{ "text key" => 1234  }.class # => Hash

# Even the current script is a class
self.class # => Object
```

Next time we will look at ways we can add to classes both our own and the core classes. For now though let's recap. We have learnt that we can use classes to group and represent logic and code. We can create instances of classes - known as objects - which can call the defined methods. Finally we have also learnt that Ruby has many classes ready for us to use right away.

Thanks for reading!
