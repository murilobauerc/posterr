## Author: Murilo Bauer

## Posterr

Posterr is a dynamic social media platform designed for quick and effective communication. Users can create posts, repost, and browse content in a minimalistic and efficient environment.

## Technologies used on the project

- React (front end)
- Elixir (back end)

## Project structure

There are two main components in the project:

- `posterr_back`: The main application that contains the business logic, services, and database interactions.
- `posterr_front`: The frontend application that contains the user interface to interact with the backend.

## Requirements to run the app

To run the application, ensure you have the following installed:

- Docker (This will handle Elixir, React, Erlang, and PostgreSQL dependencies)

### Step by step to run the app:

- The project is containerized with Docker for ease of setup and consistency across different environments. Follow these steps to get the app running:

1. **Start the Application:**

   - Run the following command at the root of the project to build the Docker image (if not already built) and start the services:

     ```sh
     docker compose up --build
     ```

   - This command initializes the database, run the seeds with default users automatically, starts the web server and backend server.

2. **Accessing the Application:**

   - Once started, the web interface is available at [http://localhost:5173](http://localhost:5173).

3. **Optional - Running tests for backend:**

   - To run the tests you can run the following command at the root of the project:

     ```sh
     docker compose -f docker-compose-backend-test.yml up --build backend-test
     ```

4. **Optional - Running tests for frontend:**

   - To run the integration tests you can run the following command at the root of the project:

     ```sh
     docker compose -f docker-compose-frontend-test.yml up --build
     ```

## Implementation details

#### Endpoints available in the application:

- GET /api/posts - Retrieves a list of posts and reposts. It accepts query parameters for filtering, sorting and pagination.
- POST /api/post - Creates a new post. Requires a JSON body with content and user_id.
- POST /api/repost - Creates a new repost. Requires a JSON body with the user_id and post_id.

#### Decisions/shortcomings of my implementation:

- The project was structured in different layers, separating the business logic from the web layer, services, entities, schemas, etc. It makes the code more maintainable, scalable and testable, in a way that it's easily extendable to add more features, functionalities and endpoints for posts and reposts and in the future to managing users.

- `GET /api/posts`: It was created an endpoint to list all the posts and reposts (if any) persisted on the database. This endpoint also accepts parameters for filtering, sorting and pagination. By default it returns the first 15 posts on the first page.
- `POST /api/post`: It was created an endpoint to create a post, giving the user id and content, also persisting on the database.
- `POST /api/repost`: It was created an endpoint to create a repost, giving the post id and user id, persising on the database.

- The backend was built using Elixir, Phoenix and Ecto, a database wrapper that allows to interact with the database using Elixir. It was used the default database, PostgreSQL, to persist the data.

- The backend application is built on top of a heavy amount of unit tests, using ExUnit. This enables more assertion and confidence in the codebase, making it easier to refactor and add new features. Test scenarios implemented for creation of posts by users, reposts of posts, scenarios of failures, edge case scenarios, etc.

- It was used the best practices of Elixir that we see in production applications on the market and functional programming concepts, like pattern matching, function chaining with pipe, immutability, let-it-crash concept, error handling, etc.

- Seeding the database with `seeds.exs`: It was created a seeds.exs file to seed the database with default users. It's a great way to have some data to test the application and see how it behaves. As the application grows, it can be used to seed the database with more data, like posts, reposts, etc to test the performance and scalability of the application.

- The frontend was built using React with Vite. To fetch the data from the backend, it was used Tanstack's Query library, to manage the data fetching, caching and updating the data in the frontend.

- The frontend application is built also on top of a considerable amount of unit tests using Jest, and Vitest for the integration tests. The integration tests consider interactions between components and the hooks that fetch the data from the backend. To see more, check the `test.jsx` files in the `posterr_front` directory.

#### Critique

_If this project were to grow and have many users and posts, which parts do you think would fail first?_

I believe it would fail on the database side, as the application would have a lot of requests to create posts, reposts, see the posts, filter for search a specific content, etc. Besides having indexes on the database, the database would be the bottleneck of the application, as it would have a lot of requests to insert, update, delete and select data. The application would have to be able to handle a large amount of traffic and requests, so it would have to be scalable and performant. The points below are suggestions to improve this.

Potential refactorings: As the system scales and more users are onboarded to system, it can have a lot of requests to the backend to create posts, see the posts, reposts and filter for seach a specific content. A suggestion would be to implement a cache mechanism to store the posts and reposts in memory, using a tool like Cachex or Redis, to avoid hitting the database every time a user requests the posts. For example, if a cache mechanism is implemented, when a user requests to see posts, it would first check if the posts are in the cache, if not, it would hit the database and store the posts in the cache, so the next time a user requests the posts, it would get the data from the cache, avoiding hitting the database again.
The cache mechanism would work for several functionalities, like the trending posts filter. The cache would store the most frequent reposts in a last given period of time - given a sort of job (Oban) mechanism - and then when a user requests to see the trending posts, the cache would return the results without hitting the database. This would be a perfect scenario as users generally search for the most trending posts and reposts.

_In a real-life situation, what steps would you take to scale this product? What other types of technology and infrastructure might you need to use?_

Scalability: A suggestion to improve the performance and scale the application would be to use a queue system to manage the posts and users, like Oban or even a event-driven architecture with SQS/Kafka, to consume the events and process them in the background, so the user doesn't need to wait for the response of the request to see the posts. Besides that, it would have more control over the retries in case of failure, etc. I personally have used Oban in other projects and it's a great tool to work with.

Scalability as a long-term solution: Another suggestion would be to implement a microservices architecture, where the application would be split into different services, like a service to manage the posts, another to manage the users, etc. This would be a great way to scale the application and have more control over the services, like monitoring, logging, etc. It would be a great way to have a more robust and scalable architecture. Event-drive architecture using Broadway behaviour, having producers responsible to publish the events (posts and reposts) and a consumer responsible to consume the events manage the posts and reposts, even users. With the event-drive approach it would have mechanisms such as retries, back-pressure to have the capability of dealing with an unusual amount of traffic, dead-letter queues, etc.

_What you would improve if you had more time._

Cache mechanisms strategies: If I had more time I would implement a cache mechanism to store the posts and reposts in memory, using a tool like Cachex or Redis, as explained above with details. There are several top-notch companies - Twitter - that uses interesting strategies such as Pull based and Push based. Basically they take that recent tweet that was made from an account, get all the followers from that account that would see the tweet, then with the tweet id (in our case post id), insert on large Redis clusters, so basically the entire timeline - what we see as posts - is a Redis cluster. This is how Twitter deals with 150M+ active users. Interesting read: [The Architecture Twitter Uses to Deal with 150M Active Users, 300K QPS, a 22 MB/S Firehose, and Send Tweets in Under 5 Seconds](https://highscalability.com/the-architecture-twitter-uses-to-deal-with-150m-active-users/)

Typescript in the frontend: Implement Typescript in the frontend application to have more control over the types and interfaces of the data that comes from the backend. It would guarantee the contracts between the frontend and the backend, making it easier to refactor and add new features.

Frontend UI: Improve the frontend interface with Tailwind CSS, it would bring benefits for example reducing the custom CSS on the code and having consistency with Tailwind classes. It brings more maintainability with utility-first approach, using utility classes shared across the application. It would have a streamlined workflow, since the code would be changed in the same file, instead of having to switch between files to change the styles.

CI/CD workflows: Implement a CI/CD pipeline to run the tests, build the application, run quality and security checks with Credo and Sobelow and deploy it to a cloud provider like AWS. I have used Github Actions in my current activities and it's been a great experience.

Logging: It was mostly used the default logger from Elixir, but it would be awesome to configure Telemetry Metrics to start emitting metrics events when a success or error happens, e.g when a post is created, a metric is emitted with the total of posts created, and when an error happens, a metric is emitted with the error message. It would be a great way to monitor the application and take action when needed.
An example of how to emit a metric when a post is created:

```elixir
defp emit_metric(metric, meta) do
    spawn(fn ->
    :telemetry.execute([:post, :creation, metric], %{total: 1}, meta)
    end)
end
```

In case of success:

```elixir
emit_metric(:success, %{})
```

And in case of post already reposted, for example:

```elixir
emit_metric(:error, %{error: :post_already_reposted})
```
