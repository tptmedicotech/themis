# Themis visual style (ASD-STE100)

| Field | Value |
| --- | --- |
| Document ID | THEMIS-STYLE-STE100-001 |
| Status | Active |
| Date | 2026-11-17 |
| Product | Themis |
| Audience | An intern who builds Themis screens |
| Visual authority | `tpt-webapp/src/styles/globals.css` |
| Screen authority | [THEMIS-SPEC-STE100-001](./THEMIS-SPEC-STE100.md) |

Write later changes to this document in ASD-STE100:

- Use short sentences.
- Use one idea in each sentence.
- Use the active voice.
- Use the same term for the same object.
- Use the verbs *do*, *set*, *show*, *use*, *read*, and *verify*.
- Do not use *handle*, *process*, or *support* when a clear verb exists.

## 1. Purpose

This document states the visual style for Themis. Copy the style from the tpt-webapp. Do not invent a second palette.

The source file is `tpt-webapp/src/styles/globals.css`. Read that file when a token in this document and the file disagree. Then update this document.

Use the light theme. The webapp defines `.dark` tokens. Do not apply the dark theme in this cut.

## 2. Words

| Term | Meaning |
| --- | --- |
| Token | A named colour or measure in `:root`. |
| Chrome | The top bar, the sidebar, and the footer. |
| Wordmark | The product name in the top bar. |
| Primary action | The one filled teal button on a screen. |
| Status chip | A short label with a status colour and a pale background. |

## 3. Type

Set the body font to Inter. Then use `ui-sans-serif`, `system-ui`, `-apple-system`, `BlinkMacSystemFont`, `Segoe UI`, and `sans-serif`.

Do not use a serif face for the application. Remove the Georgia rule from `Themis/src/app/globals.css` when you build the screens.

| Text | Size | Weight | Notes |
| --- | --- | --- | --- |
| Wordmark | 31px | 800 | Letter-spacing `-0.05em`. Line-height `1`. |
| Page title | 1.5rem | 600 | Use one title on a screen. |
| Body | 1rem | 400 | Colour `--foreground`. |
| Sidebar link | 0.925rem | 400 | Weight 700 on hover and on the active link. |
| Sidebar group label | 0.75rem | 700 | Uppercase. Letter-spacing `0.08em`. Colour `--muted-foreground`. |
| Table head | 0.75rem | 700 | Uppercase. Letter-spacing `0.025em`. |
| Field text | 0.875rem | 400 | Height 36px. |
| Footer | 12px | 400 | Colour `#98a2b3`. |

## 4. Colour

Use these tokens. Do not add a new hex value for a role that already has a token.

| Token | Value | Use |
| --- | --- | --- |
| `--teal` | `#006b68` | Primary fill. Focus ring. Active mark. |
| `--teal-dark` | `#004f4c` | Top bar start. Active link text. |
| `--teal-soft` | `#e6f5f3` | Secondary fill. Active sidebar row. |
| `--lime` | `#9ad26d` | Small brand accent only. |
| `--green` | `#69bd6f` | Second half of a two-colour wordmark. |
| `--ink` | `#101828` | Text. Same value as `--foreground`. |
| `--background` | `#f7faf9` | Page background. |
| `--card` | white | Cards, sidebar, tables. |
| `--muted` | `#f1f5f4` | Quiet fills. |
| `--muted-foreground` | `#667085` | Secondary text. |
| `--border` | `#e4e7ec` | Borders. |
| `--input` | `#d0d5dd` | Field borders. |
| `--blue` | `#2f80ed` | Information status. |
| `--blue-soft` | `#eaf3ff` | Information status background. |
| `--orange` | `#f97316` | Warning mark. |
| `--orange-soft` | `#fff3e7` | Warning mark background. |
| `--red` | `#e11d48` | Danger mark. |
| `--red-soft` | `#fff1f2` | Danger mark background. |
| `--yellow` | `#f59e0b` | Caution mark. |
| `--yellow-soft` | `#fff7e6` | Caution mark background. |

Set links and focus to `--teal`. Set a destructive action to the `--destructive` token.

Do not paint a large area with `--lime` or `--green`. Use those colours for a wordmark accent or a small mark.

## 5. Measure

| Token | Value |
| --- | --- |
| `--radius` | `0.875rem` |
| `--app-header-height` | `78px` |
| `--app-sidebar-width` | `292px` |
| `--footer-height` | `40px` |
| `--shadow` | `0 18px 45px rgba(16, 24, 40, 0.08)` |

Use `--radius` on cards and tables. Use `12px` radius on a sidebar link. Use `14px` radius on the logo tile. Use `rounded-md` on a button and on a field.

Page padding inside the content area is `24px`. Sidebar padding is `24px 18px`. Top bar padding is `0 24px`.

Hide the sidebar at a width of `1023px` or less. At `767px` or less, set the top bar height to `64px`, set top bar padding to `0 8px`, and hide the wordmark text.

## 6. Chrome

Build the signed-in shell in this order:

1. Top bar.
2. Body row: sidebar, then content.
3. Footer under the content.

The top bar is sticky. Set its height to `--app-header-height`. Set its text colour to white. Paint it with a left-to-right gradient from `--teal-dark` to `--teal`. Draw a `1px` bottom border at `rgb(255 255 255 / 12%)`.

Put the logo mark on the left. The mark is a `46px` square. Give it a `14px` radius. Use the image `tpt-webapp/public/medicotech.webp`. Set the alt text to `MedicoTech logo`.

Set the wordmark to `Themis`. Do not change the wordmark to MedicoTech. Do not copy the webapp tagline into Themis.

Right-align the reader email and the Sign out control in the top bar. Use a `48px` circle for the avatar. Set the circle fill to `#e9fbf4`. Set the circle text to `--teal-dark`.

The sidebar is sticky under the top bar. Set its width to `--app-sidebar-width`. Set its background to `--card`. Draw a right border with `--border`.

A sidebar group label uses the style in §3. A sidebar link uses colour `#344054`. On hover, and on the active route, set the background to `--teal-soft`, the text to `--teal-dark`, and the weight to `700`.

The content background is `--background`. The text colour is `--foreground`.

The footer is `40px` tall. Center the text. Show the Themis version. Set the colour to `#98a2b3`.

Show the text `Read only` in the shell, as THEMIS-SPEC-STE100-001 requires. Place it in the sidebar, under the links. Draw a `1px` border in `--border`, a `14px` radius, and `14px` padding. Set the text colour to `--teal-dark`. Set the fill to `#fbfefe`.

## 7. Controls

Copy the control roles from `tpt-webapp/src/components/ui`.

| Control | Rule |
| --- | --- |
| Primary button | Fill `--teal`. Text near-white. Height `36px`. Use one primary button for the main action on a screen. |
| Secondary button | Fill `--teal-soft`. Text near-black. |
| Outline button | White fill. Border `--input`. |
| Ghost button | No fill until hover. Hover fill `--teal-soft`. |
| Destructive button | Use only for an action that removes a Themis session, such as Sign out when you need emphasis. Do not use it to edit mirror data. |
| Link button | Teal text and an underline on hover. |
| Text field | Height `36px`. Border `--input`. Radius `rounded-md`. Placeholder colour `--muted-foreground`. |
| Focus | Show a `3px` ring at half strength of `--ring`. `--ring` is `--teal`. |
| Disabled | Set opacity to `50%`. Do not accept a click. |

Sign in is the primary button on `/sign-in`. Sign out is an outline button or a ghost button in the top bar.

Do not add a save button, a delete button, or an edit button for a mirror row.

## 8. Surfaces

A card uses the `--card` fill, a `--border` border, radius `--radius`, and shadow `--shadow`. Put one topic in one card. Card padding follows the webapp card: `24px` horizontal and `24px` vertical.

A table sits on a white surface with a `--border` border and radius `--radius`. Set the head row fill to `#f8fbfa`. Set the head text to `#475467`. Use the table-head type in §3.

A status chip uses one pair:

| State | Text | Background | Webapp class |
| --- | --- | --- | --- |
| Success | `#176b3a` | `#eaf7ed` | `status-success` |
| Warning | `#9a4b05` | `#fff7e6` | `status-warning` |
| Danger | `#b42318` | `#fff1f2` | `status-danger` |
| Information | `#175cd3` | `#eaf3ff` | `status-info` |

Use these pairs for organisation status, report status, subscription status, sync status, and AI run state.

| Stored value | Chip |
| --- | --- |
| `active`, `complete`, `completed`, `ready`, `applied` | Success |
| `draft`, `pending`, `queued`, `running`, `prepayment`, `processing`, `past_due` | Warning |
| `failed`, `deleted`, `suspended`, `cancelled`, `unpaid` | Danger |
| `open`, `uploaded`, `in_progress` | Information |

A failed sign-in message uses an alert with the destructive role. Show the sentence from the specification: `Sign-in failed.`

## 9. Lists and filters

Place filters in one row above the table. Use one field per filter named in the specification. Align the filter labels above the fields.

Keep 50 rows on a page. Place Previous and Next under the table. Use outline buttons. Disable Previous on the first page. Disable Next on the last page.

Show `No rows match this filter.` in `--muted-foreground` when the list is empty. Do not show an illustration.

Show a loading line `Loading…` in `--muted-foreground` while the server read is in progress. Do not show a second spinner style.

## 10. Numbers and time

Show a time in UTC as `YYYY-MM-DD HH:mm`. Label the column `UTC`.

Show money from cents. `99900` and currency `ZAR` is `R 999.00`. Keep the currency code beside the amount.

Show a token count and `cost_micros` as integers. Do not convert `cost_micros` into rand.

## 11. Check

Verify the built shell against this list:

1. The page background is `#f7faf9`.
2. The top bar gradient runs from `#004f4c` to `#006b68`.
3. The wordmark reads `Themis` in Inter at 31px.
4. The sidebar is `292px` wide on a desktop width.
5. The active link uses fill `#e6f5f3` and text `#004f4c`.
6. A card uses the soft shadow in §5.
7. A table head is uppercase.
8. The footer shows the version and is `40px` tall.
9. The shell shows `Read only`.
10. Focus on a field shows a teal ring.
11. The screen does not use a serif body font.
12. The screen does not use the dark theme.
