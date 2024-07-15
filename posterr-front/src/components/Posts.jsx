import { useState } from "react";
import useCreatePost from "../hooks/useCreatePost";
import usePosts from "../hooks/usePosts";
import useRepost from "../hooks/useReposts";
import ConfirmModal from "./ConfirmModal";
import "../styles/Posts.css";

const Posts = () => {
  const [newPost, setNewPost] = useState("");
  const [searchKeyword, setSearchKeyword] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [sortOption, setSortOption] = useState("latest");
  const [modalContent, setModalContent] = useState("");
  const [selectedPostId, setSelectedPostId] = useState(null);
  const { data, error, isLoading } = usePosts(searchKeyword, sortOption);

  const handleCreatePostError = (errorMessage) => {
    setModalContent(errorMessage);
    setIsModalOpen(true);
  };

  const createPostMutation = useCreatePost(handleCreatePostError);
  const repostMutation = useRepost();

  const handleSearchChange = (event) => {
    setSearchKeyword(event.target.value);
  };

  const handleSortChange = (event) => {
    const value = event.target.value;
    if (searchKeyword || value !== "latest") {
      setSortOption(value);
    }
  };

  const handleRepost = () => {
    repostMutation.mutate(
      { userId: 1, postId: selectedPostId },
      {
        onError: (error) => {
          setModalContent(error.message);
        },
        onSuccess: () => {
          setModalContent("Repost successful!");
          setIsModalOpen(false);
        },
      }
    );
  };

  const handlePostSubmit = (event) => {
    event.preventDefault();
    if (newPost.trim() && newPost.length <= 777) {
      createPostMutation.mutate(
        { content: newPost.trim(), user_id: 1 },
        {
          onSuccess: () => {
            setNewPost("");
          },
          onError: (error) => {
            console.error("Error creating post:", error);
          },
        }
      );
    }
  };

  const openRepostModal = (postId) => {
    setSelectedPostId(postId);
    setModalContent("Are you sure you want to repost this?");
    setIsModalOpen(true);
  };

  return (
    <>
      <div className="posts-page">
        <form onSubmit={handlePostSubmit} className="post-form">
          <textarea
            value={newPost}
            onChange={(e) => setNewPost(e.target.value)}
            placeholder="What's happening?"
            className="post-input"
            maxLength="777"
          />
          <div className="character-count">{newPost.length} / 777</div>
          <button
            type="submit"
            className="submit-btn"
            disabled={!newPost.trim() || createPostMutation.isLoading}
          >
            Post
          </button>
        </form>
        <div className="search-container">
          <input
            type="text"
            value={searchKeyword}
            onChange={handleSearchChange}
            placeholder="Search posts"
            className="search-input"
          />
          <button className="search-icon-btn">
            <i className="fas fa-search"></i>
          </button>
        </div>
      </div>
      <select
        onChange={handleSortChange}
        value={sortOption}
        className="sort-select"
      >
        <option value="latest">Latest</option>
        <option value="trending">Trending</option>
      </select>
      {isLoading ? (
        <p>Loading posts...</p>
      ) : error ? (
        <p>Error loading posts: {error.message}</p>
      ) : (
        <div className="posts-container">
          {data?.data.map((post) => (
            <div key={post.id} className="post">
              <p className="username">{post.username}</p>
              <p className="content">{post.content}</p>
              <button
                onClick={() => openRepostModal(post.id)}
                className="repost-btn"
                disabled={repostMutation.isLoading}
              >
                Repost
              </button>
              <p className="timestamp">
                {new Date(post.inserted_at).toLocaleString()}
              </p>
            </div>
          ))}
        </div>
      )}
      <ConfirmModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onConfirm={handleRepost}
      >
        <p>{modalContent}</p>
      </ConfirmModal>
    </>
  );
};

export default Posts;
