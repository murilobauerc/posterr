## Author: Murilo Bauer

## Posterr

Posterr is a dynamic social media platform designed for quick and effective communication. Users can create posts, repost, and browse content in a minimalistic and efficient environment.

## Implementation details

### Project structure

There are two main components in the project:

- `posterr_back`: The main application that contains the business logic, services, and database interactions.
- `posterr_front`: The frontend application that contains the user interface to interact with the backend.

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

#### Decisions/shortcomings of my implementation:

- The project was structured in different layers, separating the business logic from the web layer, services, entities, schemas, etc. It makes the code more maintainable, scalable and testable,in a way that it's easily extendable to add more features, functionalities and endpoints for managing users. Features such as offboarding, onboarding, etc.

- `GET /api/posts`: It was created an endpoint to list all the posts that were created from the frontend application, persisting on the database. This endpoint also accepts keyword filters, pagination and sorting for trending and latest posts.
- `POST /api/post`: It was created an endpoint to create a post, giving the user id and content, also persisting on the database.
- `POST /api/repost`: It was created an endpoint to create a repost, giving the post id and user id, persising on the database.

#### Critique and Future Improvements for Scalability

Potential refactorings: As the system scales and more users are onboarded to system, it can have a lot of requests to the backend to retrieve posts, reposts and filter for seach a specific content. A suggestion would be to implement a cache mechanism to store the posts and reposts in memory, using a tool like Cachex, to avoid hitting the database every time a user requests the posts. It would improve the performance and the user experience.

Scalability: A suggestion to improve the performance and scale the application would be to use a queue system to manage the posts and users, like Broadway, to consume the events and process them in the background, so the user doesn't need to wait for the response of the request to see the posts. Besides that, it would have more control over the retries in case of failure, etc. I personally have used Broadway in other projects and it's a great tool to work with.

CI/CD workflows: Another suggestion would be to implement a CI/CD pipeline to run the tests, build the application, run quality and security checks with Credo and Sobelow and deploy it to a cloud provider, AWS, etc. I have used Github Actions in my current activities and it's been a great experience.

Logging: It was mostly used the default logger from Elixir, but it would be awesome to configure Telemetry Metrics to start emitting metrics events when a success or error happens, e.g when a post is created, a metric is emitted with the total of posts created, and when an error happens, a metric is emitted with the error message. It would be a great way to monitor the application and take action when needed. An example:

```elixir
defp emit_metric(metric, meta) do
    spawn(fn ->
    :telemetry.execute([:post, :creation, metric], %{total: 1}, meta)
    end)
end
```

And in case of post already reposted:

```elixir
emit_metric(:error, %{error: :post_already_reposted})
```

Monitoring: It would be great to have a tool like Sentry or any other tool to monitor the application and receive alerts when an error happens, so it can take action and fix it as soon as possible.

#### Long-term solution for Posterr application:

Event-drive architecture using Broadway behaviour, having producers responsible to publish the events (posts and reposts) and a consumer responsible to consume the events manage the posts and reposts, even users. It would be a great solution to scale the application and have a more robust architecture. With the event-drive approach it would have mechanisms such as retries, back-pressure to have the capability of dealing with an unusual amount of traffic, dead-letter queues, etc.
