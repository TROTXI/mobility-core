/**
 * Every Ops change records why it was made. The API refuses a blank reason,
 * so forms disable their submit until this has text.
 */
export function ReasonField({
  value,
  onChange,
  disabled = false,
}: {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
}) {
  return (
    <>
      <p className="muted">All fields are required. The reason is kept in the audit history.</p>
      <label>
        Reason
        <textarea
          rows={3}
          required
          maxLength={2000}
          value={value}
          disabled={disabled}
          onChange={(event) => onChange(event.target.value)}
        />
      </label>
    </>
  );
}
