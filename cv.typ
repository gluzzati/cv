#let FONT_FAMILY = "Roboto Slab"
#let BASE_FONT_SIZE = 8pt

// Color scheme configuration
#let create_color_scheme(base_color) = {
  (
    primary: base_color.darken(60%),
    secondary: base_color.darken(10%),
    text_primary: rgb("#000000"),
    light: base_color.lighten(90%),
    white: rgb("#ffffff"),
    black: rgb("#000000"),
    sidebar_bg: rgb("#ffffff").darken(5%),
  )
}

// Font Awesome icon mappings
#let FA_ICONS = (
  location: "\u{f3c5}",  // map-marker-alt
  email: "\u{f0e0}",     // envelope
  linkedin: "\u{f08c}",  // linkedin-in
  github: "\u{f09b}",    // github
  phone: "\u{f095}"      // phone
)

// Contact item component
#let contact_item(content, icon: none, colors) = {
  let icon_el = if icon != none {
    [#text(
      font: "Font Awesome 6 Free solid",
      size: 9pt,
      fill: colors.secondary,
      FA_ICONS.at(icon)
    )]
  } else { [] }
  
  box(width: 12pt, height: 6pt, icon_el)
  h(3pt)
  [#text(fill: colors.primary, content)]
  v(-1pt)
}

// Indented text block component
#let indented_block(content, colors) = {
  set par(justify: false, leading: 0.65em)
  grid(
    columns: 2,
    h(3pt),
    text(
      hyphenate: false,
      colors.primary,
      size: 10pt,
      content
    )
  )
}

// Section title component
#let section_title(heading, colors) = {
  text(
    colors.secondary,
    size: 12pt,
    weight: "bold",
    heading + ":",
    tracking: -0.25pt
  )
  v(-5pt)
}

// Skills box component
#let skills_box(title, content, colors, min_height: auto) = {
  v(5pt)
  block(width: 100%, {
    box(
      width: 100%,
      radius: 4pt,
      height: min_height,
      stroke: (paint: colors.secondary.lighten(60%), thickness: 0.5pt),
      inset: (x: 5pt, y: 8pt),
      v(3pt) + grid(
        columns: 2,
        gutter: 5pt,
        "",
        text(colors.primary, size: 8pt, content)
      )
    )
    
    place(
      top + left,
      dy: -7pt,
      dx: 5pt,
      block(
        fill: colors.sidebar_bg,
        inset: (x: 4pt, y:3pt),
        radius: 2pt,
        text(colors.secondary, size: 8pt, title, weight: "regular")
      )
    )
  })
}

// Programming skills grid component
#let programming_skills_grid(skills, base_color, colors) = {
  grid(
    columns: (auto, 1fr),
    gutter: 8pt,
    {
      for lang in skills {
        grid(
          columns: (2fr, 1fr), 
          align: (right, left),
          gutter: 8pt,
          text(size: 7pt, lang.name),
          box(width: 100%, {
            let total-dots = 3
            grid(
              columns: (7pt,) * total-dots,
              ..range(total-dots).map(i => {
                let is-filled = i < lang.level
                circle(
                  radius: 2.5pt,
                  fill: if is-filled { base_color.darken(5%) } else { colors.secondary.lighten(50%) }
                )
              })
            )
          })
        )
        v(-5pt)
      }
      v(3pt)
    }
  )
}

// Timeline dot component
#let timeline_dot(base_color) = {
  block(
    inset: (right: 4pt), 
    place(
      dy: 0.5pt,
      box({
        place(
          dx: -2.5pt,
          dy: -2.5pt,
          circle(radius: 6pt, fill: rgb("#ffffff"))
        )
        place(
          dx: -0.5pt,
          dy: -0.5pt,
          circle(radius: 4pt, fill: base_color.lighten(80%))
        )
        place(
          circle(radius: 3.5pt, fill: base_color.lighten(40%))
        )
      })
    )
  )
}

// Timeline section component
#let timeline_section(title, elements, colors) = {
  v(25pt)
  block(
    width: 100%,
    stroke: (left: colors.primary.lighten(85%)),
    radius: (top-left: 5pt),
    inset: (top: 0pt, left: -3pt, right: 10pt),
    {
      place(
        top,
        dx: -2pt,
        dy: -13pt,
        block(
          radius: 5pt,
          text(colors.secondary.lighten(20%), size: 10pt, title, weight: "semibold")
        )
      )
      grid(columns: 2, gutter: 10pt, ..elements)
    }
  )
  v(0pt)
}

// Experience element component
#let experience_element(exp, colors) = {
  text(colors.primary, size: 10pt, weight: "semibold", exp.company)
  h(1pt)
  text(colors.primary.lighten(30%), weight: "light", size: 10pt, "|"+h(1pt)+exp.location, tracking: -0.25pt)
  v(-2pt)
  
  block(
    inset: 5pt,
    radius: 3pt,
    width: 100%,
    fill: colors.light.desaturate(50%),
    text(colors.black, size: 8pt, exp.description)
  )
  v(-5pt)
  
  block(
    inset: 5pt,
    radius: 3pt,
    fill: colors.light.desaturate(50%),
    {
      v(2pt)
      for role in exp.roles {
        grid(
          columns: (1fr, auto),
          block({
            text(colors.black, size: 9pt, weight: "semibold", role.title)
            if "keywords" in role {
              h(6pt)
              for (i, keyword) in role.keywords.enumerate() {
                if i > 0 { h(3pt) }
                box(
                  fill: colors.secondary.lighten(85%),
                  stroke: (paint: colors.secondary.lighten(70%), thickness: 0.5pt),
                  radius: 8pt,
                  inset: (x: 4pt, y: 1pt),
                  text(colors.secondary.darken(10%), size: 6pt, keyword, weight: "medium")
                )
              }
            }
          }),
          text(colors.black, size: 8pt, role.period, weight: "semibold")
        )
        v(-3pt)
        
        if "achievements" in role {
          block(
            inset: (left: 2pt),
            grid(
              columns: 2,
              column-gutter: 8pt,
              row-gutter: 5pt,
              ..role.achievements.map(achievement => {
                (
                  place(
                    top+left,
                    dy: 1.5pt,
                    box(width: 3pt, height: 3pt, fill: colors.light.darken(30%), radius: 2pt)
                  ),
                  text(colors.primary, achievement)
                )
              }).flatten()
            )
          )
        }
      }
    }
  )
  v(8pt)
}

// Main CV function
#let cv(
  name: "",
  title: "",
  location: "",
  email: "",
  linkedin: "",
  github: "",
  phone: "",
  summary: "",
  skills: (:),
  experience: (),
  education: (),
  certifications: (),
  techincal_ventures: (),
) = {
  // Document setup
  set document(author: name, title: name + " - CV")
  set page(
    margin: (left: 0mm, right: 0mm, top: 0mm, bottom: 0mm),
    numbering: "1 / 1",
  )
  set text(font: FONT_FAMILY, size: BASE_FONT_SIZE)

  // Color scheme
  let base_color = rgb("#66804d")
  let colors = create_color_scheme(base_color)

  // Layout
  grid(
    columns: (40%, 60%),
    gutter: 5mm,
    {
      // Sidebar content
      block(
        fill: colors.sidebar_bg,
        inset: (top:10pt, left:15pt, right: 15pt),
        width: 100%,
        height: 100%,
        {
          // Header
          v(25pt)
          align(
            center,
            text(colors.secondary.darken(10%), size: 24pt, tracking: -1.5pt, weight: "semibold", name)
          )
          v(10pt)

          // About section
          section_title("About Me", colors)
          indented_block(summary, colors)
          v(16pt)

          // Contact section
          section_title("Contact", colors)
          indented_block({
            contact_item(location, icon: "location", colors)
            contact_item(email, icon: "email", colors)
            contact_item(linkedin, icon: "linkedin", colors)
            contact_item(phone, icon: "phone", colors)
          }, colors)
          v(16pt)

          // Skills section
          section_title("Skills", colors)
          indented_block({
            skills_box("DOMAINS", skills.domains.join("\n"), colors)
            grid(
              columns: 2,
              gutter: 8pt,
              skills_box(
                "PROGRAMMING",
                programming_skills_grid(skills.programming, base_color, colors),
                colors,
                min_height: 82pt
              ),
              skills_box(
                "TECHNOLOGIES",
                skills.technologies.join("\n"),
                colors,
                min_height: 82pt
              )
            )
          }, colors)
        }
      )
    },
    {
      // Main content
      block(
        inset: (right: 25pt),
        breakable: true,
        {
          // Education section
          let edu_elements = education.map(edu => {
            (
              timeline_dot(base_color),
              block(
                inset: (left: 3pt),
                grid(
                  row-gutter: 6pt,
                  grid(
                    columns: (1fr, auto),
                    text(colors.primary, size: 10pt, weight: "semibold", edu.degree),
                    text(colors.secondary, size: 8pt, edu.year, weight: "semibold")
                  ),
                  text(colors.secondary, size: 9pt, edu.institution + ", " + edu.location),
                  if "details" in edu {
                    text(colors.primary, size: 8pt, style: "italic", edu.details)
                  }
                )
              )
            )
          }).flatten()
          
          v(25pt)
          timeline_section("Education", edu_elements, colors)

          // Work Experience section
          let exp_elements = experience.map(exp => {
            (timeline_dot(base_color), experience_element(exp, colors))
          }).flatten()
          
          timeline_section("Work Experience", exp_elements, colors)
          
          // Technical ventures section
          // if techincal_ventures.len() > 0 {
          //   let venture_elements = techincal_ventures.map(venture => {
          //     (timeline_dot(base_color), experience_element(venture, colors))
          //   }).flatten()
            
          //   timeline_section("Technical Ventures", venture_elements, colors)
          // }
        }
      )
    }
  )
}

// Load CV data from JSON file
#let cv_data = json("cv_data.json")

// Simple conversion for programming skills from [name, level] arrays to named tuples
#let convert_programming_skills = (skills) => {
  skills.map(s => (name: s.at(0), level: s.at(1)))
}

// Use the template with JSON data (minimal conversion needed)
#cv(
  name: cv_data.name,
  title: cv_data.title,
  location: cv_data.location,
  email: cv_data.email,
  linkedin: cv_data.linkedin,
  github: cv_data.github,
  phone: cv_data.phone,
  summary: cv_data.summary,
  skills: (
    programming: convert_programming_skills(cv_data.skills.programming),
    technologies: cv_data.skills.technologies,
    domains: cv_data.skills.domains,
  ),
  experience: cv_data.experience,
  education: cv_data.education,
  certifications: cv_data.certifications,
  techincal_ventures: cv_data.technical_ventures,
)