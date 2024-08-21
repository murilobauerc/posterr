import { renderHook, act, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import useRepost from "./useReposts";
import { describe, it, beforeEach, expect, vi } from "vitest";
import fetchMock from "fetch-mock";

const queryClient = new QueryClient();
const localhost_url = "http://localhost:4000";

const wrapper = ({ children }) => (
  <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
);

describe("useRepost", () => {
  beforeEach(() => {
    queryClient.clear();
    fetchMock.restore();
  });

  it("successfully reposts", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/repost`, {
      body: { id: 1, content: "Hello World" },
      status: 200,
    });

    const { result } = renderHook(() => useRepost(handleError), { wrapper });

    act(() => {
      result.current.mutate({ userId: 1, postId: 1 });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(fetchMock.calls()[0][0]).toBe(`${localhost_url}/api/repost`);
    expect(handleError).not.toHaveBeenCalled();
  });

  it("handles 422 error when reposting", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/repost`, {
      body: {
        message:
          "You already reposted this post. You can only repost a post once.",
      },
      status: 422,
    });

    const { result } = renderHook(() => useRepost(handleError), { wrapper });

    act(() => {
      result.current.mutate({ userId: 1, postId: 1 });
    });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith(
      "You already reposted this post. You can only repost a post once."
    );
  });

  it("handles general error when reposting", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/repost`, {
      body: { message: "Server error" },
      status: 500,
    });

    const { result } = renderHook(() => useRepost(handleError), { wrapper });

    act(() => {
      result.current.mutate({ userId: 1, postId: 1 });
    });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith("HTTP error! status: 500");
  });

  it("handles network error when reposting", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/repost`, {
      throws: new Error("Network error"),
    });

    const { result } = renderHook(() => useRepost(handleError), { wrapper });

    act(() => {
      result.current.mutate({ userId: 1, postId: 1 });
    });

    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith("Network error");
  });

  it("invalidates posts query after reposting", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/repost`, {
      body: { id: 1, content: "Hello World" },
      status: 200,
    });

    const { result } = renderHook(() => useRepost(handleError), { wrapper });

    act(() => {
      result.current.mutate({ userId: 1, postId: 1 });
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(queryClient.getQueryState(["posts"])).toBeUndefined();
  });

  it("calls handleError when reposting fails", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/repost`, {
      throws: new Error("Network error"),
    });
    const { result } = renderHook(() => useRepost(handleError), { wrapper });
    act(() => {
      result.current.mutate({ userId: 1, postId: 1 });
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith("Network error");
  });

  it("calls handleError when reposting fails with 422", async () => {
    const handleError = vi.fn();
    fetchMock.post(`${localhost_url}/api/repost`, {
      body: {
        message:
          "You already reposted this post. You can only repost a post once.",
      },
      status: 422,
    });
    const { result } = renderHook(() => useRepost(handleError), { wrapper });
    act(() => {
      result.current.mutate({ userId: 1, postId: 1 });
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(fetchMock.calls()).toHaveLength(1);
    expect(handleError).toHaveBeenCalledWith(
      "You already reposted this post. You can only repost a post once."
    );
  });
});
