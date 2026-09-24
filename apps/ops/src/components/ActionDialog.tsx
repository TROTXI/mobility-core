import {
  Button,
  Dialog,
  DialogActions,
  DialogBody,
  DialogContent,
  DialogSurface,
  DialogTitle,
  MessageBar,
  MessageBarBody,
} from '@fluentui/react-components';
import { useState, type ReactNode } from 'react';

export function ActionDialog({
  open,
  title,
  description,
  confirmLabel = 'Save',
  danger = false,
  onClose,
  onConfirm,
  children,
}: {
  open: boolean;
  title: string;
  description?: string;
  confirmLabel?: string;
  danger?: boolean;
  onClose: () => void;
  onConfirm: () => Promise<void>;
  children: ReactNode;
}) {
  const [working, setWorking] = useState(false);
  const [error, setError] = useState('');
  const confirm = async () => {
    setWorking(true);
    setError('');
    try {
      await onConfirm();
      onClose();
    } catch (value) {
      setError(value instanceof Error ? value.message : 'The operation could not be completed.');
    } finally {
      setWorking(false);
    }
  };
  return (
    <Dialog
      open={open}
      onOpenChange={(_, data) => {
        if (!data.open && !working) onClose();
      }}
    >
      <DialogSurface>
        <DialogBody>
          <DialogTitle>{title}</DialogTitle>
          <DialogContent>
            {description && <p className="muted">{description}</p>}
            {error && (
              <MessageBar intent="error">
                <MessageBarBody>{error}</MessageBarBody>
              </MessageBar>
            )}
            <div className="dialog-form">{children}</div>
          </DialogContent>
          <DialogActions>
            <Button appearance="secondary" disabled={working} onClick={onClose}>
              Cancel
            </Button>
            <Button
              appearance="primary"
              disabled={working}
              style={danger ? { background: '#a12a2a' } : undefined}
              onClick={() => void confirm()}
            >
              {working ? 'Working…' : confirmLabel}
            </Button>
          </DialogActions>
        </DialogBody>
      </DialogSurface>
    </Dialog>
  );
}
