// usePosts.test.js
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import usePosts from "./usePosts";
import { describe, it, beforeEach, expect } from "vitest";
import fetchMock from "fetch-mock";

const queryClient = new QueryClient();
const localhost_url = "http://localhost:4000";

const wrapper = ({ children }) => (
  <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
);

describe("usePosts", () => {
  beforeEach(() => {
    queryClient.clear();
    fetchMock.restore();
  });

  it("fetches posts successfully", async () => {
    fetchMock.get(`${localhost_url}/api/posts?page=1&limit=15`, {
      body: { data: [{ id: 1, content: "Hello World" }] },
      status: 200,
    });

    const { result } = renderHook(() => usePosts("", "latest", 1, 15), {
      wrapper,
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data).toEqual({
      data: [{ id: 1, content: "Hello World" }],
    });
    expect(fetchMock.calls()).toHaveLength(1);
    expect(fetchMock.calls()[0][0]).toBe(
      `${localhost_url}/api/posts?page=1&limit=15`
    );
  });

  it("fetches posts with search keyword", async () => {
    const keyword = "test";
    fetchMock.get(
      `${localhost_url}/api/posts?page=1&limit=15&keyword=${encodeURIComponent(
        keyword
      )}`,
      {
        body: { data: [{ id: 1, content: "Hello World" }] },
        status: 200,
      }
    );

    const { result } = renderHook(() => usePosts(keyword, "latest", 1, 15), {
      wrapper,
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data).toEqual({
      data: [{ id: 1, content: "Hello World" }],
    });
    expect(fetchMock.calls()).toHaveLength(1);
    expect(fetchMock.calls()[0][0]).toBe(
      `${localhost_url}/api/posts?page=1&limit=15&keyword=${encodeURIComponent(
        keyword
      )}`
    );
  });

  it("fetches posts with sort option", async () => {
    const sortOption = "trending";
    fetchMock.get(
      `${localhost_url}/api/posts?page=1&limit=15&sort=${sortOption}`,
      {
        body: { data: [{ id: 1, content: "Hello World" }] },
        status: 200,
      }
    );

    const { result } = renderHook(() => usePosts("", sortOption, 1, 15), {
      wrapper,
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data).toEqual({
      data: [{ id: 1, content: "Hello World" }],
    });
    expect(fetchMock.calls()).toHaveLength(1);
    expect(fetchMock.calls()[0][0]).toBe(
      `${localhost_url}/api/posts?page=1&limit=15&sort=${sortOption}`
    );
  });
});
