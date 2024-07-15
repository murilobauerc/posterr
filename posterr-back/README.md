````elixir
# Posterr

## Setup

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install --prefix assets`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source:

## Deployment

### Requirements to run the app

To run the application, ensure you have the following installed:

- Docker (This will handle Elixir, Erlang, and PostgreSQL dependencies)

### Step by step to run the app:

- The project is containerized with Docker for ease of setup and consistency across different environments. Follow these steps to get the app running:

1. **Start the Application:**

   - Run the following command at the root of the project to build the Docker image (if not already built) and start the services:

     ```sh
     docker-compose up --build
     ```

   - This command also initializes the database, run the seeds, and starts the web server.

2. **Run Tests (Optional):**

   - Execute the tests to ensure everything is set up correctly:

     ```sh
     docker-compose run web mix test
     ```

3. **Accessing the Application:**

   - Once started, the web interface is available at [http://localhost:4000](http://localhost:4000).

#### Endpoints available in the application:

- GET /api/posts - Retrieves a list of posts.
- POST /api/post - Creates a new post. Requires a JSON body with the title and content.
- POST /api/repost - Creates a new repost. Requires a JSON body with the user_id and post_id.

4. For more information, see the root README.md file.
````
