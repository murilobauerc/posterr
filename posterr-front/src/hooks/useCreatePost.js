import { useMutation, useQueryClient } from "@tanstack/react-query";

const createPost = async (postData) => {
  const response = await fetch("http://localhost:4000/api/post", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(postData),
  });

  if (!response.ok) {
    const errorData = await response.json();
    if (response.status === 422) {
      throw new Error(
        "You've reached the maximum of posts created today. Please try again tomorrow."
      );
    }
    throw new Error(
      errorData.message || `HTTP error! status: ${response.status}`
    );
  }

  return response.json();
};

export default function useCreatePost(handleError) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createPost,
    onSuccess: () => {
      queryClient.invalidateQueries(["posts"]);
    },
    onError: (error) => {
      handleError(error.message);
    },
  });
}
