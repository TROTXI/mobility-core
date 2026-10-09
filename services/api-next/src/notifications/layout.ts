/**
 * One look for every Trotxi email. A message is described as content, and
 * this renders it twice: an HTML version for mail apps and a plain-text
 * version for the ones that do not show HTML. Both say the same thing.
 *
 * Mail clients ignore stylesheets and most modern CSS, so the HTML is a
 * fixed-width table with inline styles, the form Gmail, Outlook and Apple
 * Mail all render the same way.
 */
export interface EmailContent {
  /** Shown by inboxes next to the subject; never visible in the body. */
  preview: string;
  heading: string;
  greeting?: string;
  paragraphs: string[];
  /** Secrets or codes the reader must copy, shown large and set apart. */
  highlight?: Array<[label: string, value: string]>;
  /** A summary such as a receipt, as label and value rows. */
  details?: Array<[label: string, value: string]>;
  action?: { label: string; url: string };
  /** Main-size paragraphs that follow the highlight, details or action. */
  closing?: string[];
  /** Small print below the main message. */
  notes?: string[];
}

export interface EmailTheme {
  /** Absolute URL of the white logo; without it the header shows the name. */
  logoUrl?: string;
  /** Staging mail says so at the top, in words that fit the message. */
  stagingNote?: string;
}

const navy = '#011935';
const green = '#01A232';
const ink = '#1C2733';
const muted = '#5B6675';
const line = '#E4E8EE';
const page = '#F3F5F8';
const font = "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";

const escape = (value: string) =>
  value.replace(
    /[&<>"']/g,
    (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!,
  );

export function renderText(content: EmailContent, theme: EmailTheme = {}): string {
  const blocks: string[] = [];
  if (theme.stagingNote) blocks.push(theme.stagingNote);
  if (content.greeting) blocks.push(content.greeting);
  blocks.push(...content.paragraphs);
  if (content.highlight?.length)
    blocks.push(content.highlight.map(([label, value]) => `${label}: ${value}`).join('\n'));
  if (content.details?.length)
    blocks.push(content.details.map(([label, value]) => `${label}: ${value}`).join('\n'));
  if (content.action) blocks.push(`${content.action.label}: ${content.action.url}`);
  if (content.closing?.length) blocks.push(...content.closing);
  if (content.notes?.length) blocks.push(...content.notes);
  blocks.push('Trotxi');
  return blocks.join('\n\n');
}

export function renderHtml(content: EmailContent, theme: EmailTheme = {}): string {
  const paragraph = (text: string, style = '') =>
    `<p style="margin:0 0 16px;font-size:16px;line-height:24px;color:${ink};${style}">${escape(text)}</p>`;
  const rows = (items: Array<[string, string]>, size: number, mono: boolean) =>
    items
      .map(
        ([label, value], index) =>
          `<tr><td style="padding:12px 0;${index ? `border-top:1px solid ${line};` : ''}font-size:14px;line-height:20px;color:${muted};white-space:nowrap;padding-right:16px;">${escape(label)}</td>` +
          `<td align="right" style="padding:12px 0;${index ? `border-top:1px solid ${line};` : ''}font-size:${size}px;line-height:${size + 6}px;font-weight:600;color:${ink};${mono ? "font-family:'SFMono-Regular',Menlo,Consolas,monospace;letter-spacing:1px;" : ''}">${escape(value)}</td></tr>`,
      )
      .join('');
  const table = (items: Array<[string, string]>, size: number, mono: boolean, fill: string) =>
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:8px 0 24px;background:${fill};border:1px solid ${line};border-radius:8px;"><tr><td style="padding:4px 20px;"><table role="presentation" width="100%" cellpadding="0" cellspacing="0">${rows(items, size, mono)}</table></td></tr></table>`;
  const body = [
    `<h1 style="margin:0 0 20px;font-size:22px;line-height:30px;font-weight:700;color:${navy};">${escape(content.heading)}</h1>`,
    content.greeting ? paragraph(content.greeting) : '',
    ...content.paragraphs.map((text) => paragraph(text)),
    content.highlight?.length ? table(content.highlight, 20, true, '#F0FAF3') : '',
    content.details?.length ? table(content.details, 15, false, '#FFFFFF') : '',
    content.action
      ? `<table role="presentation" cellpadding="0" cellspacing="0" style="margin:8px 0 24px;"><tr><td style="border-radius:8px;background:${green};"><a href="${escape(content.action.url)}" style="display:inline-block;padding:14px 28px;font-size:16px;font-weight:600;color:#FFFFFF;text-decoration:none;border-radius:8px;">${escape(content.action.label)}</a></td></tr></table>` +
        paragraph(
          `If the button does not work, copy this link into your browser: ${content.action.url}`,
          `font-size:13px;line-height:20px;color:${muted};word-break:break-all;`,
        )
      : '',
    ...(content.closing ?? []).map((text) => paragraph(text)),
    ...(content.notes ?? []).map((text) =>
      paragraph(text, `font-size:14px;line-height:21px;color:${muted};`),
    ),
  ].join('');
  const logo = theme.logoUrl
    ? `<img src="${escape(theme.logoUrl)}" width="140" height="57" alt="Trotxi" style="display:block;border:0;width:140px;height:auto;">`
    : `<span style="font-size:24px;font-weight:700;color:#FFFFFF;">Trotxi</span>`;
  const staging = theme.stagingNote
    ? `<tr><td style="padding:10px 32px;background:#FFF4D6;font-size:13px;line-height:19px;color:#7A5200;">${escape(theme.stagingNote)}</td></tr>`
    : '';
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="color-scheme" content="light"><meta name="supported-color-schemes" content="light"><title>${escape(content.heading)}</title></head>
<body style="margin:0;padding:0;background:${page};font-family:${font};">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;">${escape(content.preview)}</div>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:${page};"><tr><td align="center" style="padding:24px 12px;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:#FFFFFF;border-radius:12px;overflow:hidden;font-family:${font};">
<tr><td style="padding:24px 32px;background:${navy};">${logo}</td></tr>
${staging}
<tr><td style="padding:32px;">${body}</td></tr>
<tr><td style="padding:20px 32px;border-top:1px solid ${line};font-size:12px;line-height:18px;color:${muted};">This is a service email about your Trotxi account.<br>&copy; ${new Date().getUTCFullYear()} Trotxi</td></tr>
</table>
</td></tr></table>
</body></html>`;
}
