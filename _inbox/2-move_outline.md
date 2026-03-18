You are performing a document filing, renaming, and index-update task for a local-government meeting summary.

A file named `outline.md` already exists in the current directory.

Your job is to:
1. read `outline.md`
2. choose the best destination folder from the allowed folders provided below
3. create a normalized filename
4. move and rename the file
5. append a new entry to `outlines.json`
6. return only the final relative file path

You must follow these instructions exactly.

--------------------------------
ALLOWED DESTINATION FOLDERS
--------------------------------
Board_of_Equalization
Board_of_Zoning_and_Appeals
Budget_and_Finance_Committees
County_Commission
Elections
Health_Foundation
Health_Safety_and_Properties
Industrial_Board
Opioid_Settlement
Planning_Commission
School_Board
Solid_Waste
Weekly_Summary

You may choose only one folder from the list above.
Do not invent new folders.
If more than one folder seems plausible, choose the most specific folder supported by the content.
If nothing is clearly specific, choose the most general applicable folder from the list.

--------------------------------
INPUT ASSUMPTIONS
--------------------------------
- `outline.md` is in the current working directory.
- `outlines.json` is in the current working directory or the root directory above the current working directory.
- `outline.md` is Markdown.
- `outlines.json` is a JSON array of objects.
- The header of `outline.md` usually contains fields like:

# Meeting Outline

**Source:** ...
**Title:** ...
**Channel:** ...
**Date:** ...

- The file body contains the summarized meeting content.

--------------------------------
PRIMARY GOAL
--------------------------------
Move `outline.md` into the most appropriate allowed folder, rename it, and append a matching entry to `outlines.json`.

The filename should be:

YYYY-MM-DD-title-slug.md

Example:
2024-03-05-county-commission-meeting.md

--------------------------------
STEP 1 — READ THE FILES
--------------------------------
Open and read:
- `outline.md`
- `outlines.json`

Use both the metadata header and body of `outline.md` to determine:
- the best folder
- the best title
- the correct date

Before appending to `outlines.json`, inspect existing entries and preserve the existing JSON structure and formatting style as closely as possible.

Do not rely on personal names because transcript-derived names may be wrong.

--------------------------------
STEP 2 — DETERMINE THE MEETING DATE
--------------------------------
Determine the date to use in the filename and JSON entry.

Priority order:
1. Use the `Date:` field from the header if present.
2. If the title clearly contains the meeting date, use that.
3. If the body clearly identifies the meeting date, use that.
4. If only a publication date is available, use that date.
5. If no date can be determined with confidence, use `undated`.

When a valid date is found, convert it to:

YYYY-MM-DD

Examples:
- March 5, 2024 -> 2024-03-05
- Mar 5 2024 -> 2024-03-05
- 3/5/24 -> 2024-03-05
- 03/05/2024 -> 2024-03-05
- 2024/03/05 -> 2024-03-05

Use the meeting date when possible, not merely the upload date, unless the upload date is the only reliable date available.

--------------------------------
STEP 3 — DETERMINE THE TITLE
--------------------------------
Determine a short, descriptive meeting title.

Preferred sources:
1. `Title:` field in the header
2. meeting type inferred from the outline body

Keep only the meaningful meeting descriptor.

Examples of good titles:
- county commission meeting
- planning commission meeting
- board of adjustment meeting
- school board meeting
- budget workshop
- parks advisory board
- public hearing on zoning request

Remove generic or noisy phrases such as:
- full meeting
- official video
- livestream
- live stream
- recorded live
- meeting recording
- audio only
- part 1
- part 2
- session video
- uploaded video

Also remove duplicate date text from the title slug if the date is already being placed at the front of the filename.

For the JSON `title` field, create a readable display title in this format when possible:

<Clean Meeting Title> Outline - <Month D, YYYY>

Example:
County Commission Meeting Outline - March 5, 2024

If the date is unknown, use:
<Clean Meeting Title> Outline

--------------------------------
STEP 4 — CHOOSE THE DESTINATION FOLDER
--------------------------------
Choose the best matching folder from the allowed folder list.

Use evidence from:
- the title
- the outline sections
- repeated subject matter
- meeting body / board / commission names
- department or committee references

Examples of matching logic:
- planning, rezoning, conditional use, subdivision, site plan -> planning or zoning folder
- commission, commissioners, county business, resolutions, ordinances -> county commission / county board folder
- school board, superintendent, district, students, curriculum -> school board folder
- budget, finance, appropriations -> finance / budget folder
- roads, transportation, highway department -> transportation / roads folder
- utilities, water, sewer -> utilities folder

Do not choose based on speaker names.
Do not create a new category.
Choose exactly one folder.

--------------------------------
STEP 5 — GENERATE THE FILENAME SLUG
--------------------------------
Filename format:
- when date is known: `YYYY-MM-DD-title-slug.md`
- when date is unknown: `undated-title-slug.md`

Slug rules:
1. lowercase only
2. replace spaces with hyphens
3. remove apostrophes
4. replace ampersands with `and`
5. remove punctuation and symbols
6. keep only letters, numbers, and hyphens
7. collapse repeated hyphens into one hyphen
8. remove leading and trailing hyphens
9. do not allow spaces
10. do not allow underscores
11. do not allow parentheses or other special characters

Examples:
- County Commission Meeting -> county-commission-meeting
- Budget & Finance Committee -> budget-and-finance-committee
- Board of Zoning Appeals (Special Session) -> board-of-zoning-appeals-special-session

The final filename must be filesystem-safe.

--------------------------------
STEP 6 — HANDLE DUPLICATES AND COLLISIONS
--------------------------------
Before moving the file, check whether a file with the same destination path already exists.

Collision rules:
1. If the destination filename does not exist, use it.
2. If it exists and the existing file appears to represent the same meeting, keep the existing file and do not create a duplicate.
3. If it exists but this is clearly a different meeting or variant, append a numeric suffix:
   - `-2`
   - `-3`
   - `-4`
   etc.

Examples:
- 2024-03-05-county-commission-meeting.md
- 2024-03-05-county-commission-meeting-2.md

Only use a suffix when necessary.

If a suffix is added to the filename, use that exact final filename in the JSON entry as well.

--------------------------------
STEP 7 — MOVE AND RENAME THE FILE
--------------------------------
Move `outline.md` into the chosen folder and rename it to the final filename.

The final relative path must look like:
folder-name/YYYY-MM-DD-title-slug.md

Example:
planning-commission/2024-03-05-planning-commission-meeting.md

--------------------------------
STEP 8 — APPEND TO outlines.json
--------------------------------
After determining the final folder, filename, path, date, and display title, append a new object to the end of the JSON array in `outlines.json`.

Look at the existing entries first and match the existing key order and formatting style.

Use this object structure:

{
  "folder": "<folder name>",
  "path": "<folder>/<filename>",
  "filename": "<filename>",
  "date": "<YYYY-MM-DD or undated>",
  "title": "<display title>"
}

Field rules:
- `folder`: the chosen destination folder exactly as named in the allowed list
- `path`: the final relative path using forward slashes
- `filename`: the final filename only
- `date`: the normalized date string or `undated`
- `title`: the human-readable display title

Example:
{
  "folder": "Health_Safety_and_Properties",
  "path": "Health_Safety_and_Properties/2026-03-02-health-safety-and-properties-outline.md",
  "filename": "2026-03-02-health-safety-and-properties-outline.md",
  "date": "2026-03-02",
  "title": "Health Safety and Properties Meeting Outline - March 2, 2026"
}

Append the new object to the end of the existing JSON array.
Do not overwrite the file.
Do not reorder previous entries.
Do not change existing entries unless needed to preserve valid JSON formatting.
Ensure `outlines.json` remains valid JSON.

--------------------------------
STEP 9 — PREVENT JSON DUPLICATES
--------------------------------
Before appending, check whether `outlines.json` already contains an entry for the same final path.

Rules:
1. If an identical `path` already exists, do not append a duplicate entry.
2. If the file was renamed with a numeric suffix due to collision, append the suffixed path as a new entry.
3. Preserve all existing entries exactly as they are.

--------------------------------
STEP 10 — OUTPUT RULES
--------------------------------
Return only one line:
the final relative file path

Do not output:
- explanations
- reasoning
- JSON
- markdown code fences
- comments
- alternatives
- confidence statements

Output example:
Health_Safety_and_Properties/2026-03-02-health-safety-and-properties-outline.md