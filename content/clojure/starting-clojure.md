---
date: 2014-07-02T20:44:08+01:00
title: "Starting Clojure"
type: post
---

I've been developing Ruby for years now and I love it but I'm getting too comfortable with it. I know as well as any good developer that it isn't the best tool for every job. It's my job to be able to build the right software the right way and that should include the language selection. So, time to take the plunge and learn another language from scratch.

## Clojure basics

I selected Clojure because I find it interesting. There is something about its syntax that draws me too it. I've been enjoying Go recently thanks to how easily I can write multi-threaded applications and so Clojure is also a good choice with immutable data structures.

So first place was to the [homepage][clojure_home]. I checked out a few of the tutorials and resources and settled on [Clojure from the ground up][clojure_ground_up].

Following the instructions I installed [Leiningen][leiningen], which seems to be a `Bundle` like tool for the language which is a relief for me as it also handles the installation of Clojure itself as well.

The inclusion of a REPL is a god-send to a developer like me learning as it means I can experiment quickly and learn the basics. I then also discovered [Light Table][lighttable] which includes a live REPL feature which is brilliant as it also allows you to indent the code making it much easier to read.

Slowly I can see the patterns in the language such as `conj` for inserting additional elements into lists/sets/vectors but the fact they all work slightly differently is 'nice to know' now rather than later.

The first part that gets interesting (IMO) is the introduction of `lets` as this is where code re-use comes into play. Unfortunately the examples are lost on me a bit. My first question was how does let differ from just executing the code?

```clojure
(let [hello ""] (str "Hello, " hello "!"))
(hello "Darren")
; CompilerException java.lang.RuntimeException: Unable to resolve symbol: hello in this context, compiling:(NO_SOURCE_PATH:0:0)
```

So how is the above useful? Well let looks as though it provides a context (I could be wrong, if so please correct me). The guide introduces `fn` so adapting my previous test:

```clojure
(let [hello (fn [name] (str "Hello, " name "!"))]
  (hello "Darren")) ; => "Hello, Darren!"
```

So that worked. After declaring a function I could re-use it within that particular expression. Moving on we are introduced to `def`.

```clojure
(def hello (fn [name] (str "Hello, " name "!")))
(hello "Darren") ; => "Hello, Darren!"
```

Now this feels closer to what I know (which can be further abbreviated using `defn`). I can now build re-usable components although this is the first introduction to something mutable within Clojure.

So continuing on I learn about supporting different arities and an introduction to some of the recursion functions. Now these are only starts but with them I could adjust my method to support multiple names.

```clojure
(defn hello
     ([name] (if (coll? name)
               (str "Hello, " (apply str (interpose ", " name)) "!")
               (str "Hey " name "!"))))


(hello '("Darren" "Danika"))
```

Or I could go a little step further...

```clojure
(defn human-list
  ([names]
   (cond
    (= (count names) 0) ""
    (= (count names) 1) (peek names)
    (> (count names) 1) (str
                         (apply str
                                (interpose ", " (reverse (rest (reverse names)))))
                                " and " (peek (reverse names))))))

(human-list (list)) ; => ""
(human-list '("A")) ; => "A"
(human-list '("A" "B")) ; => "A and B"
(human-list '("A" "B" "C")) ; => "A, B and C"

(defn hello
     ([name] (if (coll? name)
               (str "Hello " (human-list name) "!")
               (str "Hey " name "!"))))


(hello "Darren") ; => "Hey Darren!"
(hello '("Darren")) ; => "Hello Darren!"
(hello '("Darren" "Danika")) ; => "Hello Darren and Danika!"
(hello '("Darren" "Danika" "George")) ; => "Hello Darren, Danika and George!"
```

I'm enjoying the language although it is a stretch for me to do these things in a functional way and trying to avoid variables. Clojure does seem to encourage small abstractions as it can get difficult to read and follow when methods get large. That may well be because I'm new to the language and do things in strange ways but it's all part of the learning experience right?

[clojure_home]: http://clojure.org "Official Clojure Site"
[clojure_ground_up]: http://aphyr.com/posts/301-clojure-from-the-ground-up-welcome "Learning Clojure Guides"
[leiningen]: http://leiningen.org/
[lighttable]: http://www.lighttable.com/
