/// Base URL: set via --dart-define=API_BASE_URL=... or uses deployed backend by default.
/// For Android emulator + local backend: --dart-define=API_BASE_URL=http://10.0.2.2:8000
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://morpheus-backend-517072344431.us-central1.run.app',
  );

  // Auth (backend: /auth)
  static String get login => '$baseUrl/auth/login';
  static String get signup => '$baseUrl/auth/signup';
  static String get me => '$baseUrl/auth/me';

  // User profile (backend: /profile)
  static String get profile => '$baseUrl/profile';
  static String get profileResumeUpload => '$baseUrl/profile/resume/upload';
  static String get profileExtractResume => '$baseUrl/profile/extract-resume';

  // Resume builder (backend: /ai-resume-builder)
  static String get resumeAnalyze => '$baseUrl/ai-resume-builder/analyze';
  static String get resumeSave => '$baseUrl/ai-resume-builder/save';
  static String get resumeData => '$baseUrl/ai-resume-builder/resume-data';
  static String get resumeGeneratePdf => '$baseUrl/ai-resume-builder/generate-pdf';

  // Portfolio (backend: /portfolio)
  static String get portfolioData => '$baseUrl/portfolio/data';
  static String get portfolioDeploy => '$baseUrl/portfolio/deploy';

  // Resume analyzer ATS (backend: /api/resume-analyzer)
  static String get resumeAnalyzerAnalyze => '$baseUrl/api/resume-analyzer/analyze';

  // Learning (backend: /api/learning)
  static String get roadmapGenerate => '$baseUrl/api/learning/generate-roadmap';
  static String get saveRoadmap => '$baseUrl/api/learning/save-roadmap';
  static String get roadmaps => '$baseUrl/api/learning/roadmaps';

  // Presentation (backend: /presentation)
  static String get presentationOutline => '$baseUrl/presentation/outline';
  static String get presentationGenerate => '$baseUrl/presentation/generate';
  static String get presentationDownload => '$baseUrl/presentation/download';

  // Flashcards (backend: /api/flashcards)
  static String get flashcardsGenerate => '$baseUrl/api/flashcards/generate';
  static String get flashcardsSave => '$baseUrl/api/flashcards/save';
  static String get flashcardsHistory => '$baseUrl/api/flashcards/history';
  static String flashcardsHistoryById(int id) => '$baseUrl/api/flashcards/history/$id';

  // Explainer (backend: /api/explainer)
  static String get explainerGenerate => '$baseUrl/api/explainer/generate';
  static String get explainerChat => '$baseUrl/api/explainer/chat';

  // Career (backend: /api/career)
  static String get careerRecommend => '$baseUrl/api/career/recommend';
  static String get careerChat => '$baseUrl/api/career/chat';
  static String get careerChatStream => '$baseUrl/api/career/chat/stream';
  static String get careerConversations => '$baseUrl/api/career/conversations';

  // Job application (backend: /api/job-application)
  static String get jobApplicationGenerate => '$baseUrl/api/job-application/generate';
  static String get jobApplicationSave => '$baseUrl/api/job-application/save';
  static String get jobApplicationMyApplications => '$baseUrl/api/job-application/my-applications';

  // Interview (backend: /api/interview)
  static String get interviewStart => '$baseUrl/api/interview/interview/start';
  static String interviewStatus(String id) => '$baseUrl/api/interview/interview/$id/status';
  static String interviewReport(String id) => '$baseUrl/api/interview/interview/$id/report';
  static String interviewGenerateReport(String id) => '$baseUrl/api/interview/interview/$id/generate-report';

  // Cold mail (backend: /api/cold-mail)
  static String get coldMailSearchCompanies => '$baseUrl/api/cold-mail/search-companies';
  static String get coldMailGenerateTemplate => '$baseUrl/api/cold-mail/generate-template';
  static String get coldMailSend => '$baseUrl/api/cold-mail/send-email';

  // Job tracker (backend: /api/jobs)
  static String get jobsSaved => '$baseUrl/api/jobs/saved';
  static String get jobsSave => '$baseUrl/api/jobs/save';
  static String get jobsAll => '$baseUrl/api/jobs/all';
  static String jobsRelevant([int limit = 50]) => '$baseUrl/api/jobs/relevant?limit=$limit';
  static String get jobsTriggerScrape => '$baseUrl/api/jobs/trigger-scrape';
}
