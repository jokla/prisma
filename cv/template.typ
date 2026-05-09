// cv/template.typ
// Giovanni Claudio CV
//
// Rendered by:  typst compile --input data=<abs-path-to-resolved.json> cv/template.typ
// Data source:  .build/resolved.json  (written by scripts/resolve-profile.js)
// Template:     brilliant-CV v3.3.0 (https://typst.app/universe/package/brilliant-cv)

#import "@preview/brilliant-cv:3.3.0": cv, cv-section, cv-entry, cv-skill, h-bar
#import "@preview/fontawesome:0.6.0": fa-phone, fa-envelope, fa-pager, fa-linkedin, fa-square-github, fa-location-dot

// ── Load resolved data ────────────────────────────────────────────────────

#let data    = json(sys.inputs.at("data"))
#let contact = data.contact
#let bio     = data.bio
#let homepage = contact.at("website", default: "").replace("https://", "").replace("http://", "")
#let cv-accent-hex = "#0085dd"
#let cv-accent = rgb(cv-accent-hex)

#let header-separator() = box({
  set text(fill: black)
  h(5pt)
  "|"
  h(5pt)
})

#let header-contact-item(icon, label, url: "") = box({
  set text(fill: black)
  icon
  h(5pt)
  if url != "" {
    link(url)[#label]
  } else {
    label
  }
})

#let join-header-items(items) = {
  box({
    for (index, item) in items.enumerate() {
      item
      if index < items.len() - 1 {
        header-separator()
      }
    }
  })
}

#let header-contact-items = (
  ..if contact.at("phone", default: "") != "" {
    (header-contact-item(
      fa-phone(),
      contact.phone,
      url: "tel:" + contact.phone.replace(" ", ""),
    ),)
  } else { () },
  ..if contact.at("email", default: "") != "" {
    (header-contact-item(
      fa-envelope(),
      contact.email,
      url: "mailto:" + contact.email,
    ),)
  } else { () },
  ..if homepage != "" {
    (header-contact-item(
      fa-pager(),
      homepage,
      url: "https://" + homepage,
    ),)
  } else { () },
  ..if contact.at("linkedin", default: "") != "" {
    (header-contact-item(
      fa-linkedin(),
      contact.linkedin,
      url: "https://www.linkedin.com/in/" + contact.linkedin,
    ),)
  } else { () },
  ..if contact.at("github", default: "") != "" {
    (header-contact-item(
      fa-square-github(),
      contact.github,
      url: "https://github.com/" + contact.github,
    ),)
  } else { () },
  ..if contact.at("location", default: "") != "" {
    (header-contact-item(fa-location-dot(), contact.location),)
  } else { () },
)

// ── Build metadata dict (replaces metadata.toml) ─────────────────────────

#let name-parts = contact.name.split(" ")

#let metadata = (
  language: "en",
  inject: (:),
  personal: (
    first_name: name-parts.first(),
    last_name:  name-parts.slice(1).join(" "),
    info: (
      "custom-1": (
        text: [#h(-5pt)#join-header-items(header-contact-items)],
      ),
    ),
  ),
  layout: (
    awesome_color:              cv-accent-hex,
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
      cv_footer:    contact.name + " | Curriculum Vitae",
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

// Format start-end date range.
#let entry-date(entry) = {
  entry.start_formatted + " - " + entry.end_formatted
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
      paint: cv-accent,
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

#let project-description(entry) = {
  let subtitle = entry.at("subtitle", default: "")
  let details = entry-description(entry)

  if subtitle != "" and details != "" {
    [
      #text(style: "italic", subtitle)
      #v(1pt)
      #details
    ]
  } else if subtitle != "" {
    text(style: "italic", subtitle)
  } else {
    details
  }
}

#let entry-tags(entry) = entry.at("tags", default: ())

#let publication-accent = cv-accent
#let skill-level-fill = cv-accent
#let skill-level-empty = rgb("#b9c9d4")

#let publication-venue-label(pub) = pub.at("venue_short", default: pub.venue)

#let entry-date-width() = {
  let configured = metadata.layout.at("date_width", default: none)
  if configured != none {
    eval(configured)
  } else if metadata.language == "fr" {
    3.4cm
  } else if metadata.language == "zh" {
    4.7cm
  } else if metadata.language == "it" {
    3.9cm
  } else {
    3.6cm
  }
}

#let entry-styles(before-entry-description-skip) = (
  a1: (value) => text(size: 10pt, weight: "bold", value),
  a2: (value) => align(right, text(weight: "medium", fill: cv-accent, style: "oblique", value)),
  b1: (value) => text(size: 8pt, fill: cv-accent, weight: "medium", smallcaps(value)),
  b2: (value) => align(right, text(size: 8pt, weight: "medium", fill: gray, style: "oblique", value)),
  dates: (value) => [
    #set list(marker: [])
    #value
  ],
  description: (value) => text(
    fill: rgb("#343a40"),
    {
      v(before-entry-description-skip)
      value
    },
  ),
  tag: (value) => align(center, text(size: 8pt, weight: "regular", value)),
)

#let render-entry-tags(tags, tag-style) = {
  for tag in tags {
    box(
      inset: (x: 0.25em),
      outset: (y: 0.25em),
      fill: rgb("#ededee"),
      radius: 3pt,
      tag-style(tag),
    )
    h(5pt)
  }
}

#let render-full-entry(
  title: "Title",
  society: "Society",
  date: "Date",
  location: "Location",
  description: "",
  logo: "",
  tags: (),
) = {
  let before-entry-skip = eval(metadata.layout.at("before_entry_skip", default: "1pt"))
  let before-entry-description-skip = eval(metadata.layout.at("before_entry_description_skip", default: "1pt"))
  let styles = entry-styles(before-entry-description-skip)
  let date-width = entry-date-width()
  let display-logo = metadata.layout.entry.display_logo
  let society-first-setting = metadata.layout.entry.display_entry_society_first

  v(before-entry-skip)
  block(
    sticky: true,
    table(
      columns: (1fr, date-width),
      inset: 0pt,
      stroke: 0pt,
      gutter: 6pt,
      align: (x, y) => if x == 1 { right } else { auto },
      table(
          columns: (if display-logo and logo != "" { 4% } else { 0% }, 1fr),
          inset: 0pt,
          stroke: 0pt,
          align: horizon,
          column-gutter: if display-logo and logo != "" { 4pt } else { 0pt },
          if logo == "" [] else {
            set image(width: 100%)
            logo
          },
          table(
            columns: auto,
            inset: 0pt,
            stroke: 0pt,
            row-gutter: 6pt,
            align: auto,
            {
              (styles.a1)(if society-first-setting { society } else { title })
            },
            {
              (styles.b1)(if society-first-setting { title } else { society })
            },
          ),
        ),
      table(
        columns: auto,
        inset: 0pt,
        stroke: 0pt,
        row-gutter: 6pt,
        align: auto,
        (styles.a2)(if society-first-setting { location } else { (styles.dates)(date) }),
        (styles.b2)(if society-first-setting { (styles.dates)(date) } else { location }),
      ),
    ),
  )

  if description != "" and description != none {
    (styles.description)(description)
  }
  render-entry-tags(tags, styles.tag)
}

#let publication-subtitle(pub) = {
  (
    publication-venue-label(pub),
    pub.at("type", default: ""),
    str(pub.year),
    pub.at("note", default: ""),
  ).filter(part => part != "").join(" | ")
}

#let publication-entry(pub) = {
  table(
    columns: (1fr),
    inset: 0pt,
    stroke: 0pt,
    row-gutter: 0.5pt,
    align: auto,
    box(width: 100%, height: 1.1em, inset: 0pt, clip: true)[
      #text(size: 9pt, weight: "bold", linked-label(pub.title, pub.at("url", default: "")))
    ],
    text(size: 8pt, weight: "medium", fill: publication-accent, smallcaps(publication-subtitle(pub))),
  )
  v(0.2pt)
}

#let interest-row(item) = {
  let title = item.at("title", default: "")
  let issuer = item.at("issuer", default: "")
  let url = item.at("url", default: "")
  let location = item.at("location", default: "")
  let details = if issuer != "" and location != "" {
    issuer + " (" + location + ")"
  } else if issuer != "" {
    issuer
  } else {
    location
  }

  table(
    columns: (20%, 1fr),
    inset: 0pt,
    column-gutter: 4pt,
    align: horizon,
    stroke: none,
    if url != "" {
      text(size: 9pt, weight: "bold", link(url)[#title])
    } else {
      text(size: 9pt, weight: "bold", title)
    },
    text(size: 9pt, details),
  )
  v(-6pt)
}

#let join-with-h-bar(items) = {
  [
    #for (index, item) in items.enumerate() {
      item
      if index < items.len() - 1 {
        [ #h-bar() ]
      }
    }
  ]
}

#let language-level-value(level-name) = {
  if level-name == "Native" {
    4
  } else if level-name == "Fluent" {
    4
  } else if level-name == "Intermediate" {
    2
  } else if level-name == "Basic" {
    1
  } else {
    2
  }
}

#let language-level-icons(level) = {
  [
    #for index in range(4) [
      #text(
        fill: if index < level { skill-level-fill } else { skill-level-empty },
        "●",
      )
      #if index < 3 [#h(0.1em)]
    ]
  ]
}

#let language-skill-entry(lang) = {
  [
    #lang.name
    #h(0.45em)
    #language-level-icons(language-level-value(lang.at("level", default: "")))
  ]
}

// ── Experience ────────────────────────────────────────────────────────────

#cv-section("Experience")

#for entry in data.experience {
  render-full-entry(
    title:       entry.role,
    society:     linked-label(entry.company, primary-entry-url(entry)),
    date:        entry-date(entry),
    location:    entry.location,
    description: entry-description(entry),
    logo:        entry-logo(entry),
    tags:        entry-tags(entry),
  )
}

// ── Skills ────────────────────────────────────────────────────────────────

#cv-section("Skills")

// Build ordered list of unique groups, then render one cv-skill per group.
#let seen-groups = data.skills.fold((), (acc, s) => {
  if acc.contains(s.group) { acc } else { acc + (s.group,) }
})
#let skill-row-gap = 2pt

#for (index, g) in seen-groups.enumerate() {
  let labels = data.skills.filter(s => s.group == g).map(s => s.label)
  cv-skill(
    type: g,
    info: join-with-h-bar(labels),
  )
  if index < seen-groups.len() - 1 or bio.at("languages", default: ()).len() > 0 {
    v(skill-row-gap)
  }
}

#let spoken-languages = bio.at("languages", default: ())

#if spoken-languages.len() > 0 {
  cv-skill(
    type: "Languages",
    info: join-with-h-bar(spoken-languages.map(lang => language-skill-entry(lang))),
  )
}

// ── Education ─────────────────────────────────────────────────────────────

#cv-section("Education")

#for entry in data.education {
  render-full-entry(
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
    render-full-entry(
      title:       linked-label(entry.name, primary-entry-url(entry)),
      society:     entry.at("organisation", default: ""),
      date:        entry-date(entry),
      location:    entry.at("location", default: ""),
      description: project-description(entry),
      tags:        entry.at("stack", default: ()),
    )
  }
}

// ── Publications ──────────────────────────────────────────────────────────

#if data.publications.len() > 0 {
  cv-section("Publications")

  for pub in data.publications {
    publication-entry(pub)
  }
}

// ── Other Interests ──────────────────────────────────────────────────────

#if data.interests != none [
  #let interests-tagline = data.interests.at("tagline", default: "")
  #let interests-summary = data.interests.at("summary", default: "")
  #let interests-cv-honors = data.interests.at("cv_honors", default: ())

  #if interests-tagline != "" or interests-summary != "" or interests-cv-honors.len() > 0 [
    #cv-section("Other interests")

    #if interests-tagline != "" [
      #text(weight: "bold", interests-tagline)
      #v(2pt)
    ]

    #if interests-cv-honors.len() > 0 [
      #for item in interests-cv-honors [
        #interest-row(item)
      ]
    ] else if interests-summary != "" [
      #interests-summary
    ]
  ]
]
