## Build a web app

Display your todos in a browser using a plain HTML file. Create a file named `todo.html` using either the REST or GraphQL endpoint.

# [REST](#tab/rest)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Todo App</title>
  <style>
    body { font-family: sans-serif; max-width: 400px; margin: 2rem auto; }
    li.done { text-decoration: line-through; color: gray; }
    #error { color: red; }
  </style>
</head>
<body>
  <h1>Todos</h1>
  <ul id="list"></ul>
  <p id="error"></p>
  <script>
    fetch('http://localhost:5000/api/Todo')
      .then(r => r.json())
      .then(data => {
        const ul = document.getElementById('list');
        data.value.forEach(todo => {
          const li = document.createElement('li');
          li.textContent = todo.title;
          if (todo.completed) li.className = 'done';
          ul.appendChild(li);
        });
      })
      .catch(() => {
        document.getElementById('error').textContent =
          'Could not reach the API. Make sure DAB is running on http://localhost:5000.';
      });
  </script>
</body>
</html>
```

# [GraphQL](#tab/graphql)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Todo App</title>
  <style>
    body { font-family: sans-serif; max-width: 400px; margin: 2rem auto; }
    li.done { text-decoration: line-through; color: gray; }
    #error { color: red; }
  </style>
</head>
<body>
  <h1>Todos</h1>
  <ul id="list"></ul>
  <p id="error"></p>
  <script>
    fetch('http://localhost:5000/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: '{ todos { items { id title completed } } }' })
    })
      .then(r => r.json())
      .then(data => {
        const ul = document.getElementById('list');
        data.data.todos.items.forEach(todo => {
          const li = document.createElement('li');
          li.textContent = todo.title;
          if (todo.completed) li.className = 'done';
          ul.appendChild(li);
        });
      })
      .catch(() => {
        document.getElementById('error').textContent =
          'Could not reach the API. Make sure DAB is running on http://localhost:5000.';
      });
  </script>
</body>
</html>
```

---

Open `todo.html` in your browser. The page fetches all todo items and renders them as a list, with completed items shown in strikethrough.

> [!IMPORTANT]
> The `cors` setting in your configuration allows this HTML file—opened from your local file system—to call the API. Without it, the browser blocks the request.
