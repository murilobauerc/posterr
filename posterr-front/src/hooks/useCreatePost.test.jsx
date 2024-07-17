import { renderHook, act, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import useCreatePost from "./useCreatePost";
import { describe, it, beforeEach, expect, vi } from "vitest";
import fetchMock from "fetch-mock";

const queryClient = new QueryClient();
const localhost_url = "http://localhost:4000";

const wrapper = ({ children }) => (
  <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
);

describe("useCreatePost", () => {
  beforeEach(() => {
    queryClient.clear();
    fetchMock.restore();
  });

  it("successfully creates a post", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/post`, {
      body: { id: 1, content: "Hello World" },
      status: 200,
    });

    const { result } = renderHook(() => useCreatePost(handleError), {
      wrapper,
    });

    act(() => {
      result.current.mutate({ content: "Hello World" });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(fetchMock.calls()[0][0]).toBe(`${localhost_url}/api/post`);
    expect(handleError).not.toHaveBeenCalled();
  });

  it("handles 422 error when creating a post", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/post`, {
      body: {
        message:
          "You've reached the maximum of posts created today. Please try again tomorrow.",
      },
      status: 422,
    });

    const { result } = renderHook(() => useCreatePost(handleError), {
      wrapper,
    });

    act(() => {
      result.current.mutate({ content: "Hello World" });
    });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith(
      "You've reached the maximum of posts created today. Please try again tomorrow."
    );
  });

  it("handles general error when creating a post", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/post`, {
      body: { message: "Server error" },
      status: 500,
    });

    const { result } = renderHook(() => useCreatePost(handleError), {
      wrapper,
    });

    act(() => {
      result.current.mutate({ content: "Hello World" });
    });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith("Server error");
  });

  it("handles network error when creating a post", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/post`, {
      throws: new Error("Network error"),
    });

    const { result } = renderHook(() => useCreatePost(handleError), {
      wrapper,
    });

    act(() => {
      result.current.mutate({ content: "Hello World" });
    });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith("Network error");
  });
});
