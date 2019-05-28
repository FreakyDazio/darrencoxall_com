---
date: 2019-05-27T14:33:29+0100
title: Using IntersectionObserver with React Hooks
type: post
---

In this article I want to demonstrate how to use the [`IntersectionObserver`][0] API built in to most web browsers to better handle infinite scrolling - a common UX pattern found in many applications. For this particular example I'm going to be using React with their new hooks API but this can be easily adapted to work with other frameworks or vanilla JavaScript. As a fan of TypeScript I will also be using TypeScript.

So what are the common issues when implementing infinite scroll?

- **Only listening to the window scroll event** - This often means failing to detect other situations where the loading point is revealed such as resizing the browser or even CSS transitions that alter the style of elements on the page.
- **Listening to the scroll event too much** - Without careful thought you can easily add code which triggers every time scrolling happens but then it can be too trigger happy firing far more than expected and slowing down the browser and it's rendering, causing a poor experience for users.
- **Harder to share exact position with URL** - With a paginated system and traditional pages, often the URL includes the information necessary to fetch the exact same page but this is often forgotten with infinite scroll solutions.
- **Unexpected** - People are growing more accustomed to certain patterns on the web, one of which is including contact information in the footer of the page. Implementing infinite scroll will suddenly stop people from accessing the bottom of the screen.

For this article I am only going to be covering the first 2 points which can be neatly handled with `IntersectionObserver`. Feel free to follow along. I will include a link to the finished code at the bottom.

So lets create our application.

    $ npx create-react-app book-list --typescript

Now for this we're going to build a basic list that loads a list of books from [Open Library][1] who provide a nice free-to-use API perfect for this example.

We need to build a new component. This new component will display our books.

```tsx
import React from 'react';

interface BookItemProps {
  title: string;
  description?: string | void;
}

const BookItem: React.FC<BookItemProps> = ({ title, description }) => {
  return (
    <li className="book">
      <h4>{ title }</h4>
      { description && <p>{ description }</p> }
    </li>
  );
}

const BookList: React.FC = () => {
  return (
    <ul className="book-list">
      <BookItem
        title="My First Book"
        description="Nothing much here yet"
       />
    </ul>
  );
}

export default BookList;
```

This basic component currently just renders a single book and that book is just dummy data so now let's fetch some real data. To do this we're going to use the `useEffect` hook with an empty array of dependencies. This acts much like the `componentWillMount` function on class based React components.

So this is our function for fetching the data.

```tsx
// Open Library Book
interface OLBook {
  title: string;
  description: { value: string } | null;
  subtitle: string | null;
}

// A simpler interface for the front end to use
interface BasicBook {
  title: string;
  description: string | void;
}

// Fetch the books and return an array of books
function fetchBooks(subject: string): Promise<BasicBook[]> {
  return fetch(
    `https://openlibrary.org/query.json?type=/type/work&subjects=${subject}&title=&description=&subtitle=`
  )
    .then<OLBook[]>(res => res.json())
    .then<BasicBook[]>(res => {
      return res.reduce((acc, book) => {
        return [
          ...acc,
          {
            title: book.subtitle ? `${book.title} ${book.subtitle}` : book.title,
            description: book.description ? book.description.value : undefined,
          },
        ];
      }, [] as BasicBook[]);
    });
}
```

So with this in place we can turn to two React hooks. [`useState`][usestate] for storing our accumulation of books and [`useEffect`][useeffect] to trigger the initial fetch whenever we get a new subject to search for.

```tsx
interface BookListProps {
  subject: string;
}

const BookList: React.FC<BookListProps> = ({ subject }) => {
  const [books, setBooks] = useState<BasicBook[]>([]);

  useEffect(() => {
    fetchBooks(subject).then(setBooks);
  }, [subject]);

  return (
    <ul className="book-list">
      { books.map(book => (
        <BookItem
          title={ book.title }
          description={ book.description }
        />
      )) }
    </ul>
  );
}
```

Okay so that works well but now we need to add in an `IntersectionObserver` to monitor the last element. Once the last item in the list becomes visible we need to fetch more data. To do this we can create a custom hook which gets attached to the `ref` of another element. This is because the `IntersectionObserver` is a browser based API and requires DOM elements. So time to hook it up.

```tsx
function useVisibility(cb: (isVisible: boolean) => void, deps: React.DependencyList): (node: any) => void {
  const intersectionObserver = useRef<IntersectionObserver | null>(null);
  return useCallback(node => {
    if (intersectionObserver.current) {
      intersectionObserver.current.disconnect();
    }

    intersectionObserver.current = new IntersectionObserver(([entry]) => {
      cb(entry.isIntersecting);
    });

    if (node) intersectionObserver.current.observe(node);
  }, deps); // eslint-disable-line react-hooks/exhaustive-deps
}
```

So what on earth does this all do?

- using [`useRef`][useref] to create a mutable container for our `IntersectionObserver`. This is so we can remove them once the callback needs switching.
- then with [`useCallback`][usecallback] we can produce a function used for subscribing to `ref` changes. We can trigger the callback whenever the `ref` changes allowing us to observe the visibility of that particular DOM node.
- within the callback we make sure to disconnect any un-used observers and register any new ones when required.
- The observer is configured to call the provided callback with the value of `isIntersecting` which provides a basic boolean if the element is visible in the browser window or not.

How do we use this then? Well first we add the offset to the book fetching code.

```tsx
// Open Library Book
interface OLBook {
  key: string;
  title: string;
  description: { value: string } | null;
  subtitle: string | null;
}

// A simpler interface for the front end to use
interface BasicBook {
  key: string;
  title: string;
  description: string | void;
}

// Fetch the books and return an array of books
function fetchBooks(subject: string, offset: number = 0): Promise<BasicBook[]> {
  return fetch(
    `https://openlibrary.org/query.json?type=/type/work&subjects=${subject}&offset=${offset}&title=&description=&subtitle=`
  )
    .then<OLBook[]>(res => res.json())
    .then<BasicBook[]>(res => {
      return res.reduce((acc, book) => {
        return [
          ...acc,
          {
            key: book.key,
            title: book.subtitle ? `${book.title} ${book.subtitle}` : book.title,
            description: book.description ? book.description.value : undefined,
          },
        ];
      }, [] as BasicBook[]);
    });
}
```

The eagle eyed will notice that I've' also added a key to the books, as using a key when rendering a list is recommended. We also need to make the `ref` for the `BookItem` accessible and so we can use [`React.forwardRef`][forwardref] and amend the `Props` accordingly.

```tsx
interface BookItemProps {
  title: string;
  description?: string | void;
  ref?: React.Ref<HTMLLIElement>;
}

const BookItem: React.ForwardRefExoticComponent<BookItemProps> =
  React.forwardRef(({ title, description }, ref: React.Ref<HTMLLIElement>) => {
    return (
      <li className="book" ref={ ref }>
        <h4>{ title }</h4>
        { description && <p>{ description }</p> }
      </li>
    );
  });
```

Finally we can now orchastrate the loading and make use of the new hook to load subsequent pages.

```tsx
const BookList: React.FC<BookListProps> = ({ subject }) => {
  const [books, setBooks] = useState<BasicBook[]>([]);
  const [offset, setOffset] = useState(0);

  const lastBook = useVisibility(visible => {
    if (visible) {
      fetchBooks(subject, offset)
        .then(newBooks => {
          setOffset(offset + newBooks.length);
          setBooks([...books, ...newBooks]);
        });
    }
  }, [subject, offset, books]);

  useEffect(() => {
    fetchBooks(subject).then(newBooks => {
      setBooks(newBooks);
      setOffset(newBooks.length);
    });
  }, [subject]);

  return (
    <ul className="book-list">
      { books.map(book => (
        <BookItem
          key={ book.key }
          title={ book.title }
          description={ book.description }
          ref={ books[books.length - 1].key === book.key ? lastBook : null }
        />
      )) }
    </ul>
  );
}
```

So here we can simply make use of the hook, declaring our dependencies. By doing so we ensure that a new callback is created when we get new data which maintains the state of our observer.

Now if we try this in the browser we get our infinite scrolling behaviour whilst making use of a much more optimized approach to checking if we need to begin loading data. We also have kept all our components in their base functional forms and have extracted the logic for checking visibility so it can be easily used by other components.

All in all this is a nice solution. Now of course there are some things missing: loading states; checking if there is any data left to load; and handling error responses; but this is a great first step to improving the performance and impact of implementing infinite scroll.

The full code and working project can be found on GitHub [here][project].

[0]: https://developer.mozilla.org/en-US/docs/Web/API/IntersectionObserver
[1]: https://openlibrary.org/
[forwardref]: https://reactjs.org/docs/forwarding-refs.html
[useref]: https://reactjs.org/docs/hooks-reference.html#useref
[usecallback]: https://reactjs.org/docs/hooks-reference.html#usecallback
[usestate]: https://reactjs.org/docs/hooks-reference.html#usestate
[useeffect]: https://reactjs.org/docs/hooks-reference.html#useeffect
[project]: https://github.com/dcoxall/react-book-list
