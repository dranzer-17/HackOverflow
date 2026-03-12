import React from "react";

interface ResumeData {
  personal: {
    name: string;
    title?: string;
    email: string;
    phone: string;
    location: string;
    linkedin?: string;
    github?: string;
    website?: string;
  };
  summary?: string;
  experience: Array<{
    title: string;
    company: string;
    location: string;
    startDate: string;
    endDate: string;
    bullets: string[];
  }>;
  education: Array<{
    degree: string;
    school: string;
    location: string;
    graduationDate: string;
    gpa?: string;
  }>;
  skills: {
    languages: string[];
    frameworks: string[];
    tools: string[];
  };
  projects?: Array<{
    name: string;
    description: string;
    technologies: string[];
    link?: string;
  }>;
}

function RichText({ text }: { text: string }) {
  // Ensure text is a string
  const textStr = typeof text === "string" ? text : String(text || "");
  const parts = textStr.split(/(\*\*[^*]+\*\*)/g);
  return (
    <>
      {parts.map((p, i) =>
        p.startsWith("**") && p.endsWith("**") ? (
          <strong key={i}>{p.slice(2, -2)}</strong>
        ) : (
          <span key={i}>{p}</span>
        )
      )}
    </>
  );
}

function HR() {
  return <hr style={{ border: "none", borderTop: "1px solid #000", margin: "6px 0" }} />;
}

function SectionTitle({ children }: { children: React.ReactNode }) {
  return (
    <div style={{ fontWeight: "bold", fontSize: 12, letterSpacing: 1, marginBottom: 5 }}>
      {children}
    </div>
  );
}

export default function ClassicTemplate({ data }: { data: ResumeData }) {
  const { personal, skills, experience, education, projects, summary } = data;

  const allSkills = [
    ...(skills?.languages?.length ? [{ label: "Languages:", value: skills.languages.join(", ") }] : []),
    ...(skills?.frameworks?.length ? [{ label: "Frameworks:", value: skills.frameworks.join(", ") }] : []),
    ...(skills?.tools?.length ? [{ label: "Dev Tools:", value: skills.tools.join(", ") }] : []),
  ];

  return (
    <div style={{ fontFamily: "'Times New Roman', Times, serif", fontSize: 10.5, color: "#000", background: "#fff", maxWidth: 780, margin: "0 auto", padding: "36px 52px", lineHeight: 1.45 }}>

      {/* HEADER */}
      <div style={{ textAlign: "center", marginBottom: 6 }}>
        <div style={{ fontSize: 26, fontWeight: "bold", letterSpacing: 3, textTransform: "uppercase", marginBottom: 7 }}>
          {personal?.name}
        </div>
        <div style={{ display: "flex", justifyContent: "center", flexWrap: "wrap", gap: "0 14px", fontSize: 10.5 }}>
          {personal?.phone && <span>☎ {personal.phone}</span>}
          {personal?.email && <span>✉ {personal.email}</span>}
          {personal?.location && <span>📍 {personal.location}</span>}
          {personal?.linkedin && <span>in {personal.linkedin}</span>}
          {personal?.github && <span>⌥ {personal.github}</span>}
          {personal?.website && <span>🌐 {personal.website}</span>}
        </div>
      </div>

      <HR />

      {/* SKILLS */}
      {allSkills.length > 0 && (
        <section style={{ margin: "6px 0" }}>
          <SectionTitle>TECHNICAL SKILLS</SectionTitle>
          {allSkills.map((row, i) => (
            <div key={i} style={{ display: "flex", gap: 6, marginBottom: 2, fontSize: 10.5 }}>
              <span style={{ fontWeight: "bold", whiteSpace: "nowrap", minWidth: 90 }}>{row.label}</span>
              <span>{row.value}</span>
            </div>
          ))}
        </section>
      )}

      <HR />

      {/* EXPERIENCE */}
      {experience?.length > 0 && (
        <section style={{ margin: "6px 0" }}>
          <SectionTitle>EXPERIENCE</SectionTitle>
          {experience.map((job, i) => (
            <div key={i} style={{ marginBottom: i < experience.length - 1 ? 10 : 0 }}>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <span style={{ fontWeight: "bold", fontSize: 11 }}>{job.company}</span>
                <span style={{ fontSize: 10.5 }}>{job.startDate} – {job.endDate}</span>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <span style={{ fontStyle: "italic", fontSize: 10.5 }}>{job.title}</span>
                <span style={{ fontStyle: "italic", fontSize: 10.5 }}>{job.location}</span>
              </div>
              <ul style={{ margin: "3px 0 0 16px", padding: 0 }}>
                {job.bullets?.map((b, j) => (
                  <li key={j} style={{ marginBottom: 3, fontSize: 10.5, lineHeight: 1.45 }}><RichText text={b} /></li>
                ))}
              </ul>
            </div>
          ))}
        </section>
      )}

      {/* PROJECTS */}
      {projects && projects.length > 0 && (
        <>
          <HR />
          <section style={{ margin: "6px 0" }}>
            <SectionTitle>PERSONAL PROJECTS</SectionTitle>
            {projects.map((proj, i) => (
              <div key={i} style={{ marginBottom: i < projects.length - 1 ? 10 : 0 }}>
                <div style={{ display: "flex", justifyContent: "space-between" }}>
                  <div>
                    <span style={{ fontWeight: "bold", fontSize: 11 }}>{proj.name}</span>
                    {proj.technologies?.length > 0 && (
                      <span style={{ fontStyle: "italic", fontSize: 10.5 }}> | {proj.technologies.join(", ")}</span>
                    )}
                  </div>
                  {proj.link && (
                    <a href={proj.link} style={{ fontSize: 10.5, fontWeight: "bold", color: "#000", textDecoration: "underline" }}>
                      Git ↗
                    </a>
                  )}
                </div>
                {proj.description && (
                  <div style={{ fontSize: 10.5, lineHeight: 1.45, marginTop: 3 }}>{proj.description}</div>
                )}
              </div>
            ))}
          </section>
        </>
      )}

      {/* EDUCATION */}
      {education && education.length > 0 && (
        <>
          <HR />
          <section style={{ margin: "6px 0" }}>
            <SectionTitle>EDUCATION</SectionTitle>
            {education.map((edu, i) => (
              <div key={i} style={{ marginBottom: i < education.length - 1 ? 8 : 0 }}>
                <div style={{ display: "flex", justifyContent: "space-between" }}>
                  <span style={{ fontWeight: "bold", fontSize: 11 }}>{edu.school}</span>
                  <span style={{ fontSize: 10.5 }}>{edu.graduationDate}</span>
                </div>
                <div style={{ fontStyle: "italic", fontSize: 10.5 }}>{edu.degree}</div>
              </div>
            ))}
          </section>
        </>
      )}

    </div>
  );
}