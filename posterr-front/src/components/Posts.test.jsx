import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import Posts from "./Posts";
import { test, vi } from "vitest";

vi.mock("../hooks/useCreatePost");
vi.mock("../hooks/useReposts");
vi.mock("../hooks/usePosts");
vi.mock("./ConfirmModal", () => ({
  __esModule: true,
  default: ({ children, isOpen, onConfirm }) =>
    isOpen ? (
      <div>
        <div>{children}</div>
        <button onClick={onConfirm}>Confirm</button>
      </div>
    ) : null,
}));

import useCreatePost from "../hooks/useCreatePost";
import useReposts from "../hooks/useReposts";
import usePosts from "../hooks/usePosts";

describe("Posts Component", () => {
  beforeEach(() => {
    vi.restoreAllMocks();

    vi.mocked(useCreatePost).mockImplementation(() => ({
      mutate: vi.fn((postData, { onSuccess }) => {
        onSuccess();
      }),
      isLoading: false,
    }));

    vi.mocked(useReposts).mockImplementation(() => ({
      mutate: vi.fn((postData, { onError }) => {
        onError({ message: "You already reposted this post." });
      }),
      isLoading: false,
    }));

    vi.mocked(usePosts).mockImplementation(() => ({
      data: {
        data: [
          {
            id: 1,
            content: "Sample Post",
            username: "user1",
            inserted_at: new Date().toISOString(),
          },
        ],
      },
      isLoading: false,
      error: null,
      isFetching: false,
    }));
  });

  afterAll(() => {
    vi.restoreAllMocks();
  });

  test("updates textarea on user input", async () => {
    render(<Posts />);
    const inputElement = screen.getByPlaceholderText("What's happening?");
    fireEvent.change(inputElement, { target: { value: "New post content" } });
    expect(inputElement.value).toBe("New post content");
  });

  test("clears textarea on form submission", async () => {
    render(<Posts />);
    const inputElement = screen.getByPlaceholderText("What's happening?");
    const buttonElement = screen.getByText("Post");

    fireEvent.change(inputElement, { target: { value: "New post content" } });
    fireEvent.click(buttonElement);

    await waitFor(() => {
      expect(inputElement.value).toBe("");
    });
  });

  test("displays loading state", () => {
    vi.mocked(usePosts).mockImplementation(() => ({
      data: null,
      isLoading: true,
      error: null,
    }));

    render(<Posts />);
    expect(screen.getByText("Loading posts...")).toBeInTheDocument();
  });

  test("displays error message", () => {
    vi.mocked(usePosts).mockImplementation(() => ({
      data: null,
      isLoading: false,
      error: { message: "Failed to fetch posts" },
    }));

    render(<Posts />);
    expect(
      screen.getByText("Error loading posts: Failed to fetch posts")
    ).toBeInTheDocument();
  });

  test("handles repost errors correctly", async () => {
    render(<Posts />);

    await waitFor(() => {
      expect(screen.getByText("Sample Post")).toBeInTheDocument();
    });

    const repostButton = screen.getByText("Repost");
    fireEvent.click(repostButton);

    await waitFor(() => {
      expect(
        screen.getByText("Are you sure you want to repost this?")
      ).toBeInTheDocument();
    });

    const confirmButton = screen.getByText("Confirm");
    fireEvent.click(confirmButton);

    await waitFor(() => {
      expect(
        screen.getByText("You already reposted this post.")
      ).toBeInTheDocument();
    });
  });

  test("displays posts", async () => {
    vi.mocked(usePosts).mockImplementation(() => ({
      isLoading: false,
      data: {
        data: [
          {
            id: 1,
            content: "Hello World",
            username: "user1",
            inserted_at: "2020-01-01T00:00:00Z",
          },
        ],
      },
      error: null,
    }));

    render(<Posts />);

    await waitFor(() => {
      expect(screen.getByText("Hello World")).toBeInTheDocument();
    });
  });

  test("displays reposted posts", async () => {
    vi.mocked(usePosts).mockImplementation(() => ({
      isLoading: false,
      data: {
        data: [
          {
            id: 1,
            content: "Hello World",
            username: "user1",
            inserted_at: "2020-01-01T00:00:00Z",
          },
        ],
      },
      error: null,
    }));

    vi.mocked(useReposts).mockImplementation(() => ({
      mutate: vi.fn((postData, { onSuccess }) => {
        onSuccess();
      }),
      isLoading: false,
    }));

    render(<Posts />);

    await waitFor(() => {
      expect(screen.getByText("Hello World")).toBeInTheDocument();
    });

    const repostButton = screen.getByText("Repost");
    fireEvent.click(repostButton);

    await waitFor(() => {
      expect(screen.getByText("Hello World")).toBeInTheDocument();
    });
  });

  test("creates 5 posts and tries to create the sixth and returns an error", async () => {
    vi.mocked(usePosts).mockImplementation(() => ({
      isLoading: false,
      data: {
        data: [
          {
            id: 1,
            content: "Hello World 1",
            username: "user1",
            inserted_at: "2020-01-01T00:00:00Z",
          },
          {
            id: 2,
            content: "Hello World 2",
            username: "user1",
            inserted_at: "2020-01-01T00:00:00Z",
          },
          {
            id: 3,
            content: "Hello World 3",
            username: "user1",
            inserted_at: "2020-01-01T00:00:00Z",
          },
          {
            id: 4,
            content: "Hello World 4",
            username: "user1",
            inserted_at: "2020-01-01T00:00:00Z",
          },
          {
            id: 5,
            content: "Hello World 5",
            username: "user1",
            inserted_at: "2020-01-01T00:00:00Z",
          },
        ],
      },
      error: null,
    }));

    vi.mocked(useCreatePost).mockImplementation((handleCreatePostError) => ({
      mutate: vi.fn(() => {
        handleCreatePostError("You can only create 5 posts.");
      }),
      isLoading: false,
    }));

    render(<Posts />);

    const inputElement = screen.getByPlaceholderText("What's happening?");
    const buttonElement = screen.getByText("Post");

    fireEvent.change(inputElement, { target: { value: "New post content" } });
    fireEvent.click(buttonElement);

    await waitFor(() => {
      expect(
        screen.getByText("You can only create 5 posts.")
      ).toBeInTheDocument();
    });
  });
});
