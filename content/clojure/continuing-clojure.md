---
date: 2014-07-24T21:59:27+01:00
title: "Continuing Clojure"
type: post
---

After getting the hang of some of the basics in my last article ([Starting Clojure][starting_clojure]) I decided it was time to throw myself into some *slightly* more challenging puzzles. This post will be very code centric with some brief notes about what led me to my solutions/failures.

Still learning I turned to [4Clojure][4clojure] which has some nice in browser challenges. I continued using LightPaper to experiment throughout as the lack of information can be annoying when starting.

### Problem 21: Nth Element

This was the first problem my head refused to solve quickly. At first I considered using a for loop but that felt nasty and not particularly functional. Then the answer suddenly dawned on me (and it is particularly easy).

    #((vec %1) %2) ; equivalent to (nth vec i)

### Problem 22: Count a sequence

Now this time I liked the challenge and the first time I attempted it I had a google for some tips which helped immensely. The tip was that we are effectively going through a list to generate a single number. There's a common functional way of doing that.

    ; reduce a seq but use 1 instead of the actual value
    ; I had to set the initial value to 0 to prevent inc \H
    (fn [x] (reduce (fn [total s] (inc total)) 0 (seq x)))

### Problem 23: Reverse a sequence

This challenge I recognised I could use the difference between the different collection types and iteratively build a list using each of the elements in the set.

    #(reduce conj '() %)
    ; at this point I decided reduce is my friend

### Problem 26: Fibonacci

So this should be easy (and is when you know how) but it took me a while and it is solved in the official docs. I did pretty much copy it but I did make sure to learn how it worked and so please do the same.

    #(take %
      ;; take the first n results
           (map first
            ;; take the first value of each fib pair
                (iterate
                ;; infinitely add each result and the next number
                 (fn
                   [[a b]]
                   [b (+ a b)])
                 [1 1])))
                  ;; seed the sequence with [1 1] (+ 1 1)

### Problem 28: Flatten a Sequence

Time to write our own `flatten`. I failed miserably here and cheated but the [solution][prob_28] my Google fu found did teach me some of the core functions I hadn't yet learnt and how they can be used.

    ;; loop through the list applying concat
    ;; but recursive so we convert the elements
    ;; in the list to a concat'ed list
    (fn x
      [ls]
       (if (sequential? ls)
         (mapcat x ls)
         (list ls)))

### Problem 39: Interleave Two Sequences

Without using the `interleave` method I was reminded of something I read about `map` which would allow me to combine the results of multiple sequences. I ended up using `map` and `flatten` to compress the final output. I'm sure there are tidier ways of doing this that also support sequences of sequences.

    (fn [a b] (flatten (map (fn [x y] (list x y)) a b)))

## Enough?

So at this point in all honesty my attention was wavering. I had started to look into actual applications of the language including how best to test them.

I hope this hasn't been too tedious to read but often seeing solutions can help cement how flexible Clojure is and how all the core building blocks can fit together to solve very different problems.

If you have followed along and have gotten a better understanding of the language now is a good point to just dive in yourself. Keep the docs at hand and make a start at writing a trivial application.

Any future articles on Clojure will likely be focused on specific libraries (I'm particularly interested in exploring the async features).

Once again my solutions are just that, mine. I'm new to the language and so if you see something I could do better then comment as it is super helpful for me to see the *better* ways of achieving results.

Thanks for reading! I hope it helped.

[starting_clojure]: http://www.darrencoxall.com/clojure/starting-clojure/ "Getting started with Clojure"
[prob_28]: http://stackoverflow.com/questions/16155597/clojure-what-is-wrong-with-my-implementation-of-flatten
[4clojure]: http://www.4clojure.com "Browser based Clojure challenges"
