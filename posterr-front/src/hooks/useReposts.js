import { useMutation, useQueryClient } from "@tanstack/react-query";

const repost = async ({ userId, postId }) => {
  const response = await fetch(`http://localhost:4000/api/repost`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ user_id: userId, post_id: postId }),
  });

  if (!response.ok) {
    if (response.status === 422) {
      throw new Error(
        "You already reposted this post. You can only repost a post once."
      );
    }
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return response.json();
};

export default function useRepost(handleError) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: repost,
    onSuccess: () => {
      queryClient.invalidateQueries(["posts"]);
    },
    onError: (error) => {
      handleError(error.message);
    },
  });
}
