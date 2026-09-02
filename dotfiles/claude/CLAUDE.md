# User-Level Instructions

## End of Session
Use the work-logger skill to log progress at the end of sessions with code changes or commits.

## Research: always download the papers
When doing any literature research, **download every source you cite** into the
project's `papers/` directory. Do not work from abstracts, search snippets or
publisher landing pages when a PDF is obtainable.

- Try, in order: the DOI/publisher page, arXiv (`/pdf/` — WebFetch reports the
  content as corrupted binary but still saves the file to the session
  tool-results directory, so copy it out and run `pdftotext`), the PMC mirror
  (`pmc.ncbi.nlm.nih.gov/articles/PMCxxxxxxx/`), institutional repositories,
  and Semantic Scholar (`api.semanticscholar.org/graph/v1/paper/DOI:<doi>`)
  for at least the abstract.
- **When a paper cannot be retrieved, stop and ask Adam to paste the link or
  drop the PDF in.** List the exact papers still missing, with their DOIs, so
  he can fetch them in one pass. Do not silently downgrade the claim to an
  abstract-level citation without saying so.
- Publishers that reliably block automated fetching: AIP (`pubs.aip.org`),
  IEEE Xplore, ScienceDirect, and SAGE PDFs (SAGE *full text* via
  `journals.sagepub.com/doi/<doi>` does render, so read it there).
- **MDPI works via `mdpi-res.com`**, not `mdpi.com`. Pattern:
  `https://mdpi-res.com/d_attachment/<journal>/<journal>-<vol>-<art>/article_deploy/<journal>-<vol>-<art>.pdf`
  — e.g. `drones-10-00258`. Try the `-v2` suffix if the plain one 404s.
- **Semantic Scholar finds open mirrors**: the `openAccessPdf` field of
  `api.semanticscholar.org/graph/v1/paper/DOI:<doi>?fields=openAccessPdf,externalIds`
  surfaces the arXiv id of paywalled journal papers. Then `curl -sL` the arXiv
  PDF with a browser User-Agent (WebFetch chokes on large PDFs; curl does not).
- Record what was and was not retrieved alongside the deliverable, and keep the
  evidence tier honest about it ([V] only for papers actually read at source).

## Derived documents: write them from the text, not from memory

Whenever a document is **derived** from another one — a summary, a brief, an abstract, a README from
code, release notes from a diff, slides from a report — produce it by **reading the current source**,
not by writing from your understanding of the topic.

Writing from understanding is what makes a summary readable, and it is also what makes it wrong. It
reproduces the source's *earlier* state: every correction made after you formed the understanding is
silently reverted. This has already happened once — a 7-page brief reproduced a claim ("every one of
sixteen studies…") that the parent document had been corrected to scope ("of the six that were read…"),
because the brief was written from the topic rather than from the file.

- **Derive last.** Finish and verify the source before producing anything downstream from it. A brief
  written against a moving document is a draft, whatever it looks like.
- **Verify the derived document against the source, claim by claim.** For a short document this is
  tens of statements and takes minutes. Skipping it is how a summary ends up more confident and less
  accurate than the thing it summarises.
- **Say which is authoritative.** State in the derived document that the source governs where they
  disagree, so a reader who notices a conflict knows which to trust.
- **Never present a derived document as finished while its source is still changing.** Call it a
  working draft and say what it is waiting on.

The same applies in reverse: if the source changes after the derived document exists, the derived
document is stale until re-checked. Treat it as a build artefact, not as a deliverable.
