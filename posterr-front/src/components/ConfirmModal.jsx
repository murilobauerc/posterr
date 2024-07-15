import "../styles/ConfirmModal.css";
import PropTypes from "prop-types";

const ConfirmModal = ({
  isOpen,
  onClose,
  onConfirm,
  children,
  errorMessage,
}) => {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        {errorMessage && <p className="error-message">{errorMessage}</p>}
        <button className="close-button" onClick={onClose}></button>
        {children}
        <div className="modal-actions">
          <button onClick={onConfirm} className="confirm-button">
            Confirm
          </button>
          <button onClick={onClose} className="cancel-button">
            Cancel
          </button>
        </div>
      </div>
    </div>
  );
};

ConfirmModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
  onConfirm: PropTypes.func.isRequired,
  children: PropTypes.node,
  errorMessage: PropTypes.string,
};

export default ConfirmModal;
