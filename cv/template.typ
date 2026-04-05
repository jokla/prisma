// cv/template.typ
// Giovanni Claudio — CV
//
// Rendered by:  typst compile --input data=<abs-path-to-resolved.json> cv/template.typ
// Data source:  .build/resolved.json  (written by scripts/resolve-profile.js)
// Template:     brilliant-CV v3.3.0 (https://typst.app/universe/package/brilliant-cv)

#import "@preview/brilliant-cv:3.3.0": cv, cv-section, cv-entry, cv-skill, cv-honor, h-bar

// ── Load resolved data ────────────────────────────────────────────────────

#let data    = json(sys.inputs.at("data"))
#let contact = data.contact
#let bio     = data.bio
#let homepage = contact.website.replace("https://", "").replace("http://", "")

// ── Build metadata dict (replaces metadata.toml) ─────────────────────────

#let name-parts = contact.name.split(" ")

#let metadata = (
  language: "en",
  inject: (:),
  personal: (
    first_name: name-parts.first(),
    last_name:  name-parts.slice(1).join(" "),
    info: (
      email:     contact.email,
      phone:     contact.phone,
      github:    contact.github,
      linkedin:  contact.linkedin,
      homepage:  homepage,
      location:  contact.location,
      extraInfo: "",
    ),
  ),
  layout: (
    awesome_color:              "skyblue",
    paper_size:                 "a4",
    font_size:                  "9.5pt",
    fonts: (
      regular_fonts: ("Source Sans Pro",),
      header_font: "Roboto",
    ),
    before_section_skip:        "5pt",
    before_entry_skip:          "3pt",
    before_entry_description_skip: "1pt",
    header: (
      display_profile_photo: true,
      header_align: "left",
    ),
    entry: (
      display_entry_society_first: false,
      display_logo: true,
    ),
    footer: (
      display_page_counter: true,
      display_footer: true,
    ),
  ),
  lang: (
    en: (
      header_quote: data.pitch,
      cv_footer:    contact.name + " — Curriculum Vitae",
      letter_footer: "",
    ),
  ),
)

// ── Document setup ────────────────────────────────────────────────────────

#show: cv.with(
  metadata,
  profile-photo: image(bio.photo.src),
)

// ── Helpers ───────────────────────────────────────────────────────────────

// Return the first logo image for an entry, or "" if none.
#let entry-logo(entry) = {
  let images = entry.at("images", default: ())
  if images.len() > 0 { image(images.at(0).src) } else { "" }
}

// Resolve the most relevant primary URL for an entry.
#let primary-entry-url(entry) = {
  let direct-url = entry.at("url", default: "")
  let website = entry.at("website", default: "")
  let videos = entry.at("youtube", default: ())

  if direct-url != "" {
    direct-url
  } else if website != "" {
    website
  } else if videos.len() > 0 {
    "https://www.youtube.com/watch?v=" + videos.first().id
  } else {
    ""
  }
}

// Render a clickable label.
#let linked-label(label, url) = {
  if url == "" {
    label
  } else {
    link(url)[#label]
  }
}

// Format start–end date range.
#let entry-date(entry) = {
  entry.start_formatted + " – " + entry.end_formatted
}

// Render highlights as a list, or "" if empty.
#let highlight-links(entry, highlight) = {
  let explicit-links = entry.at("highlight_links", default: ())
  let video-links = entry.at("youtube", default: ())
    .filter(video => video.at("label", default: "") != "")
    .map(video => (
      label: video.label,
      url: "https://www.youtube.com/watch?v=" + video.id,
    ))

  (explicit-links + video-links).filter(item =>
    item.at("label", default: "") != "" and
    item.at("url", default: "") != "" and
    highlight.contains(item.label)
  )
}

#let inline-link-label(label) = {
  underline(
    stroke: (
      paint: rgb("#6ea7c5"),
      thickness: 0.5pt,
      dash: "dotted",
      cap: "round",
    ),
    offset: 2.2pt,
    label,
  )
}

#let linkify-text(value, links) = {
  if links.len() == 0 {
    value
  } else {
    let item = links.first()
    let rest = links.slice(1)
    let label = item.at("label", default: "")
    let url = item.at("url", default: "")

    if label == "" or url == "" or not value.contains(label) {
      linkify-text(value, rest)
    } else {
      let parts = value.split(label)

      [
        #for (index, part) in parts.enumerate() {
          linkify-text(part, rest)
          if index < parts.len() - 1 {
            link(url)[#inline-link-label(label)]
          }
        }
      ]
    }
  }
}

#let render-highlight(highlight, entry) = {
  linkify-text(highlight, highlight-links(entry, highlight))
}

#let entry-description(entry) = {
  let hl = entry.at("highlights", default: ())
  if hl.len() > 0 { list(..hl.map(h => [#render-highlight(h, entry)])) } else { "" }
}

#let entry-tags(entry) = entry.at("tags", default: ())

// ── Experience ────────────────────────────────────────────────────────────

#cv-section("Experience")

#for entry in data.experience {
  cv-entry(
    title:       entry.role,
    society:     linked-label(entry.company, primary-entry-url(entry)),
    date:        entry-date(entry),
    location:    entry.location,
    description: entry-description(entry),
    logo:        entry-logo(entry),
    tags:        entry-tags(entry),
  )
}

// ── Education ─────────────────────────────────────────────────────────────

#cv-section("Education")

#for entry in data.education {
  cv-entry(
    title:       linked-label(entry.degree, primary-entry-url(entry)),
    society:     entry.institution,
    date:        entry-date(entry),
    location:    entry.location,
    description: entry-description(entry),
    logo:        entry-logo(entry),
  )
}

// ── Projects ──────────────────────────────────────────────────────────────

#if data.projects.len() > 0 {
  cv-section("Projects")

  for entry in data.projects {
    cv-entry(
      title:       linked-label(entry.name, primary-entry-url(entry)),
      society:     entry.at("organisation", default: ""),
      date:        entry-date(entry),
      location:    entry.at("location", default: ""),
      description: entry-description(entry),
      tags:        entry.at("stack", default: ()),
    )
  }
}

// ── Publications ──────────────────────────────────────────────────────────

#if data.publications.len() > 0 {
  cv-section("Publications")

  for pub in data.publications {
    cv-honor(
      date:   str(pub.year),
      title:  pub.title,
      issuer: pub.venue,
      url:    pub.at("url", default: ""),
    )
  }
}

// ── Skills ────────────────────────────────────────────────────────────────

#cv-section("Skills")

// Build ordered list of unique groups, then render one cv-skill per group.
#let seen-groups = data.skills.fold((), (acc, s) => {
  if acc.contains(s.group) { acc } else { acc + (s.group,) }
})

#for g in seen-groups {
  let labels = data.skills.filter(s => s.group == g).map(s => s.label)
  cv-skill(
    type: g,
    info: labels.join([#h-bar()]),
  )
}
