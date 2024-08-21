import { render, screen, fireEvent } from "@testing-library/react";
import ConfirmModal from "./ConfirmModal";
import { describe, it, expect, vi } from "vitest";

describe("ConfirmModal", () => {
  it("renders correctly when open", () => {
    render(
      <ConfirmModal isOpen={true} onClose={vi.fn()} onConfirm={vi.fn()}>
        <p>Modal Content</p>
      </ConfirmModal>
    );
    expect(screen.getByText("Modal Content")).toBeInTheDocument();
  });

  it("does not render when closed", () => {
    render(
      <ConfirmModal isOpen={false} onClose={vi.fn()} onConfirm={vi.fn()}>
        <p>Modal Content</p>
      </ConfirmModal>
    );
    expect(screen.queryByText("Modal Content")).not.toBeInTheDocument();
  });

  it("calls onClose when close button is clicked", () => {
    const onClose = vi.fn();
    render(
      <ConfirmModal isOpen={true} onClose={onClose} onConfirm={vi.fn()}>
        <p>Modal Content</p>
      </ConfirmModal>
    );
    fireEvent.click(screen.getByText("Cancel"));
    expect(onClose).toHaveBeenCalled();
  });

  it("calls onConfirm when confirm button is clicked", () => {
    const onConfirm = vi.fn();
    render(
      <ConfirmModal isOpen={true} onClose={vi.fn()} onConfirm={onConfirm}>
        <p>Modal Content</p>
      </ConfirmModal>
    );
    fireEvent.click(screen.getByText("Confirm"));
    expect(onConfirm).toHaveBeenCalled();
  });

  it("displays error message when provided", () => {
    render(
      <ConfirmModal
        isOpen={true}
        onClose={vi.fn()}
        onConfirm={vi.fn()}
        errorMessage="Error!"
      >
        <p>Modal Content</p>
      </ConfirmModal>
    );
    expect(screen.getByText("Error!")).toBeInTheDocument();
  });
});
