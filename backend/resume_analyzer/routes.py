from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from .schema import ResumeAnalysisResponse
from auth.router import get_current_user
from gemini_service import gemini_service
from PyPDF2 import PdfReader
import io
import json
from typing import Any, Dict, List


router = APIRouter(prefix="/resume-analyzer", tags=["Resume Analyzer"])


def extract_resume_text(pdf_content: bytes) -> str:
    """Extract text from PDF resume bytes."""
    try:
        pdf_file = io.BytesIO(pdf_content)
        pdf_reader = PdfReader(pdf_file)

        text = ""
        for page in pdf_reader.pages:
            extracted = page.extract_text() or ""
            text += extracted + "\n"

        return text.strip()
    except Exception as e:
        raise Exception(f"Failed to extract text from PDF: {str(e)}")


def _extract_text_from_gemini_response(response: Dict[str, Any]) -> str:
    """
    Convert a Gemini JSON response into a plain text string by
    concatenating all candidate parts.
    """
    candidates: List[Dict[str, Any]] = response.get("candidates", []) or []
    if not candidates:
        raise ValueError("Empty Gemini response: no candidates returned")

    parts = candidates[0].get("content", {}).get("parts", []) or []
    text_chunks: List[str] = []
    for part in parts:
        if isinstance(part, dict) and "text" in part:
            text_chunks.append(str(part["text"]))
    text = "".join(text_chunks).strip()
    if not text:
        raise ValueError("Gemini response did not contain any text content")
    return text


async def analyze_resume_with_gemini(resume_text: str, job_description: str) -> dict:
    """Analyze resume against job description using Gemini AI."""
    try:
        prompt = f"""You are an expert ATS (Applicant Tracking System) resume analyzer and career consultant. Analyze the following resume against the job description with STRICT scoring standards and provide EXACT, DETAILED feedback with SPECIFIC EXAMPLES.

**RESUME TEXT:**
{resume_text}

**JOB DESCRIPTION:**
{job_description}

**SCORING CRITERIA (BE STRICT - Lower scores for common issues):**

**ATS Score (0-100) - Strict Evaluation:**
- 90-100: Excellent ATS optimization (rare) - Perfect keyword density, clean formatting, proper structure, no ATS blockers
- 80-89: Good ATS optimization - Minor keyword gaps or formatting issues
- 70-79: Acceptable but needs improvement - Missing important keywords, some formatting concerns
- 60-69: Below average - Significant keyword gaps, formatting issues that may confuse ATS
- 50-59: Poor ATS optimization - Major keyword mismatches, problematic formatting
- Below 50: Very poor - Critical ATS blockers present

**Deduct points for:**
- Missing critical keywords from job description (-5 to -15 points per major keyword category)
- Poor formatting (tables, columns, graphics, headers/footers) (-10 to -20 points)
- No quantifiable achievements/metrics (-10 points)
- Missing skills section or poorly organized skills (-10 points)
- Generic language instead of specific technical terms (-5 to -10 points)
- Missing contact information or unprofessional email (-5 points)
- Inconsistent date formats or missing dates (-5 points)
- Use of images, charts, or graphics that ATS can't parse (-15 points)
- Non-standard fonts or special characters that break parsing (-10 points)

**Readiness Score (0-100) - Strict Evaluation:**
- 90-100: Exceptional match (rare) - Meets all requirements + most nice-to-haves
- 80-89: Strong match - Meets all core requirements, some nice-to-haves
- 70-79: Good match - Meets most core requirements, missing some important skills
- 60-69: Moderate match - Meets basic requirements but significant gaps
- 50-59: Weak match - Missing multiple core requirements
- Below 50: Poor match - Does not meet minimum requirements

**Deduct points for:**
- Missing required years of experience (-10 to -20 points)
- Missing critical technical skills mentioned in requirements (-10 to -15 points each)
- Missing required education/certifications (-10 to -15 points)
- No relevant work experience examples (-15 to -20 points)
- Missing soft skills mentioned in JD (-5 to -10 points)
- Experience doesn't align with job level (too junior/senior) (-10 points)

**INSTRUCTIONS:**
1. Calculate ATS score (0-100) using STRICT criteria above - be conservative, most resumes should score 60-80
2. Calculate readiness score (0-100) using STRICT criteria above - penalize missing requirements heavily
3. Identify SPECIFIC gaps with EXACT examples from the resume and job description
4. List strengths with SPECIFIC examples showing alignment
5. Provide actionable tips with CONCRETE EXAMPLES of what to add/change
6. Calculate overall match percentage (weighted average: 40% ATS score + 60% readiness score)
7. Provide detailed recommendations with SPECIFIC examples

**EXAMPLES OF GOOD FEEDBACK:**

**Gaps (be specific):**
- "Missing React experience: Job requires '2+ years React', resume only shows 'JavaScript' without React framework mention"
- "No quantifiable metrics: Resume states 'Improved performance' but lacks specific numbers. Example: Should say 'Improved API response time by 40%' or 'Reduced server costs by $50K annually'"
- "Missing AWS experience: Job requires 'cloud platforms (AWS, GCP, Azure)', resume mentions 'cloud computing' but no specific platform names"

**Tips (be actionable with examples):**
- "Add React keyword: Change 'Built web applications' to 'Built responsive web applications using React and TypeScript'"
- "Quantify achievements: Replace 'Managed database' with 'Managed PostgreSQL database serving 1M+ daily queries, reducing query time by 35%'"
- "Add missing skill: Include 'AWS' explicitly in skills section if you have cloud experience, even if brief"

**Recommendations (be specific):**
- "Add a dedicated 'Technical Skills' section listing: React, TypeScript, Python, FastAPI, PostgreSQL, AWS (match exact terms from job description)"
- "Restructure work experience bullets to start with action verbs and include metrics: 'Developed RESTful APIs using Python/FastAPI that processed 10K+ requests/day'"
- "Remove graphics/charts if present - ATS systems cannot parse visual elements. Use text-based formatting only"

**REQUIRED JSON STRUCTURE:**
{{
  "ats_score": 72,
  "readiness_score": 68,
  "match_percentage": 69.6,
  "tips": [
    "Add React keyword explicitly: Change 'Built web applications' to 'Built responsive web applications using React and TypeScript' - ATS searches for exact keyword matches",
    "Quantify achievements: Replace 'Improved system performance' with 'Improved API response time by 40% (from 500ms to 300ms)' - Numbers are critical for ATS",
    "Add AWS explicitly: Job requires 'cloud platforms (AWS, GCP, Azure)' but resume only mentions 'cloud computing' - Use exact platform names"
  ],
  "gaps": [
    "Missing React framework: Job requires '2+ years React', resume shows JavaScript experience but no React mention - This is a critical requirement",
    "No quantifiable metrics: Resume uses vague terms like 'improved', 'managed', 'developed' without specific numbers - Example: 'Reduced costs' should be 'Reduced infrastructure costs by $50K annually'",
    "Missing AWS experience: Job requires 'cloud platforms (AWS, GCP, Azure)', resume mentions cloud computing but no specific platform names - ATS won't match without exact keywords"
  ],
  "strengths": [
    "Strong Python background: Resume shows '3 years Python development' matching job requirement of 'Python and backend framework experience'",
    "Relevant work experience: 'Software Engineer at TechCorp' aligns with job's '2+ years professional software engineering experience' requirement",
    "Good educational match: 'BS Computer Science' matches job's education expectations"
  ],
  "recommendations": [
    "Add dedicated 'Technical Skills' section with exact keywords: React, TypeScript, Python, FastAPI, PostgreSQL, AWS, Git, Docker - Match exact terms from job description for ATS parsing",
    "Restructure 3 work experience bullets to include metrics: Example format - 'Developed RESTful APIs using Python/FastAPI processing 10K+ daily requests, reducing latency by 35%'",
    "Remove any graphics/charts/images if present - ATS cannot parse visual elements. Use plain text formatting with standard fonts (Arial, Calibri, Times New Roman)"
  ]
}}

**IMPORTANT:**
- Be STRICT with scores - most resumes should score 70-80, not 85-95
- Provide EXACT examples from the actual resume text and job description
- Give SPECIFIC, actionable feedback with concrete examples of what to change
- Identify issues with precision - quote exact phrases from resume when pointing out problems
- Return ONLY valid JSON with NO markdown formatting, NO code blocks, NO extra text
- Ensure all scores are numbers, not strings
"""

        raw_response = await gemini_service.generate(prompt)
        result_text = _extract_text_from_gemini_response(raw_response)

        # Clean up response - remove markdown code blocks if present
        if result_text.startswith("```json"):
            result_text = result_text[7:]
        if result_text.startswith("```"):
            result_text = result_text[3:]
        if result_text.endswith("```"):
            result_text = result_text[:-3]
        result_text = result_text.strip()

        # Parse JSON response
        analysis_data = json.loads(result_text)

        return analysis_data

    except json.JSONDecodeError as e:
        snippet = result_text[:500] if "result_text" in locals() and result_text else "No response"
        raise Exception(f"Failed to parse Gemini response as JSON: {e}\nResponse: {snippet}")
    except Exception as e:
        raise Exception(f"Failed to analyze resume with Gemini: {e}")


@router.post("/analyze", response_model=ResumeAnalysisResponse)
async def analyze_resume(
    resume: UploadFile = File(...),
    job_description: str = Form(...),
    current_user: dict = Depends(get_current_user),
):
    """
    Analyze resume against job description
    Returns ATS score, readiness score, tips, gaps, and recommendations
    """
    try:
        # Validate file type
        if not resume.filename.endswith(".pdf"):
            raise HTTPException(status_code=400, detail="Only PDF files are supported")

        # Read PDF content
        pdf_content = await resume.read()

        # Extract text from PDF
        resume_text = extract_resume_text(pdf_content)

        if not resume_text or len(resume_text.strip()) < 50:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Could not extract sufficient text from PDF. "
                    "Please ensure the PDF contains readable text."
                ),
            )

        if not job_description or len(job_description.strip()) < 20:
            raise HTTPException(
                status_code=400,
                detail="Job description is required and must be at least 20 characters long",
            )

        # Analyze with Gemini
        analysis = await analyze_resume_with_gemini(resume_text, job_description)

        return ResumeAnalysisResponse(
            success=True,
            ats_score=float(analysis.get("ats_score", 0)),
            readiness_score=float(analysis.get("readiness_score", 0)),
            tips=analysis.get("tips", []),
            gaps=analysis.get("gaps", []),
            strengths=analysis.get("strengths", []),
            recommendations=analysis.get("recommendations", []),
            match_percentage=float(analysis.get("match_percentage", 0)),
            message="Resume analysis completed successfully",
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to analyze resume: {e}")

