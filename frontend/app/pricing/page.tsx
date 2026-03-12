"use client";

import { useState } from "react";
import { Check, X, ShieldCheck, Zap, ChevronDown, ChevronUp } from "lucide-react";
import SplashCursor from "@/components/SplashCursor";
import { MarketingHeader } from "@/components/MarketingHeader";
import { MarketingNavbar } from "@/components/MarketingNavbar";

interface Feature {
  label: string;
  free: string | false;
  pro: string;
}

const features: Feature[] = [
  { label: "Cold Mail generation", free: "10 mails / day", pro: "1,000 mails / day" },
  { label: "AI Resume Builder", free: "3 resumes", pro: "Unlimited resumes" },
  { label: "Resume ATS Analyzer", free: "5 analyses / month", pro: "Unlimited analyses" },
  { label: "Career Recommender", free: "3 queries / month", pro: "Unlimited queries" },
  { label: "Interview Agent (mock interviews)", free: "3 sessions / month", pro: "Unlimited sessions" },
  { label: "Learning Path Generator", free: "5 paths / month", pro: "Unlimited paths" },
  { label: "AI Flashcard Generator", free: "10 sets / month", pro: "Unlimited sets" },
  { label: "Portfolio Builder", free: "1 portfolio", pro: "Unlimited portfolios" },
  { label: "Presentation Builder", free: "3 decks / month", pro: "Unlimited decks" },
  { label: "Job Tracker", free: "Track up to 20 jobs", pro: "Unlimited jobs + analytics" },
  { label: "Job Application Assistant", free: "10 applications / month", pro: "Unlimited applications" },
  { label: "AI Concept Explainer", free: "20 explanations / month", pro: "Unlimited explanations" },
  { label: "WhatsApp Integration", free: false, pro: "Full access" },
  { label: "Support", free: "Community support", pro: "Priority email support" },
];

const VISIBLE_COUNT = 5;

export default function PricingPage() {
  const [expanded, setExpanded] = useState(false);
  const visibleFeatures = expanded ? features : features.slice(0, VISIBLE_COUNT);

  return (
    <main className="min-h-screen bg-background relative overflow-hidden">
      <SplashCursor />
      <MarketingHeader />
      <MarketingNavbar />
      <section className="relative z-10 py-32 px-4">
        <div className="container mx-auto max-w-5xl">
          <div className="text-center mb-16">
            <h1 className="text-4xl md:text-5xl font-semibold tracking-tight mb-4 text-foreground">
              Simple, transparent <span className="text-foreground/80">pricing</span>
            </h1>
            <p className="text-base text-foreground/50 max-w-2xl mx-auto">
              Start for free and upgrade when you need more. No hidden fees, no surprises.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-3xl mx-auto pt-4">
            {/* Free Plan */}
            <div className="bg-[var(--glass-bg)] backdrop-blur-xl border border-[var(--glass-border)] rounded-2xl p-8 flex flex-col hover:border-foreground/30 transition-all relative overflow-hidden shadow-[0_0_0_1px_rgba(255,255,255,0.1),0_0_20px_rgba(255,255,255,0.05),inset_0_0_20px_rgba(255,255,255,0.05)]">
              <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-white/20 via-transparent to-transparent opacity-50 pointer-events-none" />
              <div className="absolute inset-0 bg-gradient-to-br from-foreground/5 via-transparent to-foreground/10 pointer-events-none" />
              <div className="relative z-10 flex flex-col h-full">
                <div className="mb-8">
                  <div className="flex items-center gap-2 mb-2">
                    <ShieldCheck className="w-5 h-5 shiny-blue-text" />
                    <h3 className="text-xl font-semibold text-foreground">Free</h3>
                  </div>
                  <div className="mt-4">
                    <span className="text-5xl font-bold text-foreground">$0</span>
                    <span className="text-foreground/50 text-sm ml-1">/month</span>
                  </div>
                  <p className="text-sm text-foreground/50 mt-2">Perfect for getting started</p>
                </div>

                <ul className="flex-1 space-y-3 mb-4">
                  {visibleFeatures.map((f) => (
                    <li key={f.label} className="flex items-start gap-3">
                      {f.free !== false ? (
                        <Check className="w-4 h-4 shiny-blue-text shrink-0 mt-0.5" />
                      ) : (
                        <X className="w-4 h-4 text-foreground/25 shrink-0 mt-0.5" />
                      )}
                      <span className={`text-sm ${f.free !== false ? "text-foreground/70" : "text-foreground/30"}`}>
                        <span className="font-medium">{f.label}</span>
                        {f.free !== false && (
                          <span className="block text-xs text-foreground/45 mt-0.5">{f.free}</span>
                        )}
                      </span>
                    </li>
                  ))}
                </ul>

                <button
                  onClick={() => setExpanded((v) => !v)}
                  className="flex items-center gap-1 text-xs text-foreground/40 hover:text-foreground/70 transition mb-6 font-medium"
                >
                  {expanded ? (
                    <span className="flex items-center gap-1"><ChevronUp className="w-4 h-4" /> Show less</span>
                  ) : (
                    <span className="flex items-center gap-1"><ChevronDown className="w-4 h-4" /> Show {features.length - VISIBLE_COUNT} more features</span>
                  )}
                </button>

                <button className="w-full bg-[var(--glass-bg)] backdrop-blur-xl border border-[var(--glass-border)] hover:border-foreground/30 hover:bg-foreground/5 text-foreground px-6 py-3 rounded-lg font-medium transition-all cursor-pointer relative overflow-hidden shadow-[0_0_0_1px_rgba(255,255,255,0.1),0_0_15px_rgba(255,255,255,0.05),inset_0_0_15px_rgba(255,255,255,0.05)]">
                  <span className="relative z-10">Get Started Free</span>
                </button>
              </div>
            </div>

            {/* Pro Plan */}
            <div className="bg-[var(--glass-bg)] backdrop-blur-xl shiny-blue-border rounded-2xl p-8 flex flex-col relative hover:shadow-lg transition-all -mt-4">
              <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-white/30 via-transparent to-transparent opacity-60 pointer-events-none" />
              <div className="absolute inset-0 bg-gradient-to-br from-[var(--shiny-blue-glow)]/10 via-transparent to-[var(--shiny-blue-glow)]/5 pointer-events-none rounded-2xl" />
              <div className="absolute -top-3 left-1/2 -translate-x-1/2 z-20">
                <span className="shiny-blue-bg text-white px-4 py-1.5 rounded-full text-xs font-medium shadow-lg">
                  Most Popular
                </span>
              </div>

              <div className="relative z-10 flex flex-col h-full">
                <div className="mb-8">
                  <div className="flex items-center gap-2 mb-2">
                    <Zap className="w-5 h-5 shiny-blue-text" />
                    <h3 className="text-xl font-semibold text-foreground">Pro</h3>
                  </div>
                  <div className="mt-4">
                    <span className="text-5xl font-bold text-foreground">$20</span>
                    <span className="text-foreground/50 text-sm ml-1">/month</span>
                  </div>
                  <p className="text-sm text-foreground/50 mt-2">For serious job seekers</p>
                </div>

                <ul className="flex-1 space-y-3 mb-4">
                  {visibleFeatures.map((f) => (
                    <li key={f.label} className="flex items-start gap-3">
                      <Check className="w-4 h-4 shiny-blue-text shrink-0 mt-0.5" />
                      <span className="text-sm text-foreground/70">
                        <span className="font-medium">{f.label}</span>
                        <span className="block text-xs text-foreground/45 mt-0.5">{f.pro}</span>
                      </span>
                    </li>
                  ))}
                </ul>

                <button
                  onClick={() => setExpanded((v) => !v)}
                  className="flex items-center gap-1 text-xs text-foreground/40 hover:text-foreground/70 transition mb-6 font-medium"
                >
                  {expanded ? (
                    <span className="flex items-center gap-1"><ChevronUp className="w-4 h-4" /> Show less</span>
                  ) : (
                    <span className="flex items-center gap-1"><ChevronDown className="w-4 h-4" /> Show {features.length - VISIBLE_COUNT} more features</span>
                  )}
                </button>

                <button className="w-full shiny-blue-bg text-white px-6 py-3 rounded-lg font-medium transition-all cursor-pointer relative overflow-hidden">
                  <span className="relative z-10 drop-shadow-[0_0_4px_rgba(255,255,255,0.6)]">
                    Start Free Trial
                  </span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}

