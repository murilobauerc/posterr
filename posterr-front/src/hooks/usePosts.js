import { useQuery } from "@tanstack/react-query";

const fetchPosts = async (searchKeyword, sortOption, page = 1, limit = 15) => {
  let url = `http://localhost:4000/api/posts?page=${page}&limit=${limit}`;

  if (searchKeyword) {
    url += `&keyword=${encodeURIComponent(searchKeyword)}`;
  }
  if (sortOption && sortOption !== "latest") {
    url += `&sort=${sortOption}`;
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error("Network response was not ok");
  }
  return response.json();
};

export default function usePosts(
  searchKeyword,
  sortOption,
  page = 1,
  limit = 15
) {
  return useQuery({
    queryKey: ["posts", searchKeyword, sortOption, page, limit],
    queryFn: () => fetchPosts(searchKeyword, sortOption, page, limit),
    keepPreviousData: true,
  });
}
