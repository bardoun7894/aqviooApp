"use client";

import {
  useState,
  useEffect,
  useLayoutEffect,
  useRef,
  useCallback,
  type ReactNode,
} from "react";
import Link from "next/link";
import Image from "next/image";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import Lenis from "lenis";
import {
  Video,
  Image as ImageIcon,
  Wand2,
  Mic,
  Palette,
  Ratio,
  Sun,
  Moon,
  Menu,
  X,
  Download,
  Play,
  ChevronLeft,
  Sparkles,
  Zap,
  CreditCard,
  Mail,
  ExternalLink,
  Check,
  Star,
  Shield,
  Clock,
  Smartphone,
} from "lucide-react";

gsap.registerPlugin(ScrollTrigger);

/* ═══════════════════════════════════════════════════
   UTILITY
   ═══════════════════════════════════════════════════ */

function cn(...classes: (string | undefined | false)[]) {
  return classes.filter(Boolean).join(" ");
}

/* ═══════════════════════════════════════════════════
   THEME HOOK
   ═══════════════════════════════════════════════════ */

function useTheme() {
  const [theme, setTheme] = useState<"dark" | "light">("dark");

  useEffect(() => {
    const stored = localStorage.getItem("aqvioo-theme") as
      | "dark"
      | "light"
      | null;
    if (stored) {
      setTheme(stored);
      document.documentElement.setAttribute("data-theme", stored);
    }
  }, []);

  const toggle = useCallback(() => {
    const next = theme === "dark" ? "light" : "dark";
    setTheme(next);
    localStorage.setItem("aqvioo-theme", next);
    if (next === "light") {
      document.documentElement.setAttribute("data-theme", "light");
    } else {
      document.documentElement.removeAttribute("data-theme");
    }
  }, [theme]);

  return { theme, toggle };
}

/* ═══════════════════════════════════════════════════
   LENIS HOOK
   ═══════════════════════════════════════════════════ */

function useLenis() {
  useEffect(() => {
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      smoothWheel: true,
    });

    lenis.on("scroll", ScrollTrigger.update);

    gsap.ticker.add((time) => {
      lenis.raf(time * 1000);
    });

    gsap.ticker.lagSmoothing(0);

    return () => {
      lenis.destroy();
    };
  }, []);
}

/* ═══════════════════════════════════════════════════
   GSAP SCROLL REVEAL HOOK
   ═══════════════════════════════════════════════════ */

function useScrollReveal(
  ref: React.RefObject<HTMLElement | null>,
  options?: {
    y?: number;
    x?: number;
    scale?: number;
    stagger?: number;
    duration?: number;
    delay?: number;
    start?: string;
    children?: boolean;
  }
) {
  useLayoutEffect(() => {
    if (!ref.current) return;
    const el = ref.current;
    const targets = options?.children ? el.children : el;

    const ctx = gsap.context(() => {
      gsap.from(targets, {
        y: options?.y ?? 60,
        x: options?.x ?? 0,
        scale: options?.scale ?? 1,
        opacity: 0,
        duration: options?.duration ?? 1,
        delay: options?.delay ?? 0,
        stagger: options?.stagger ?? 0,
        ease: "power3.out",
        scrollTrigger: {
          trigger: el,
          start: options?.start ?? "top 85%",
        },
      });
    });

    return () => ctx.revert();
  }, [ref, options]);
}

/* ═══════════════════════════════════════════════════
   REUSABLE COMPONENTS
   ═══════════════════════════════════════════════════ */

const GlassCard = ({
  children,
  className,
  gradient = false,
}: {
  children: ReactNode;
  className?: string;
  gradient?: boolean;
}) => (
  <div
    className={cn(
      "glass rounded-3xl overflow-hidden",
      gradient && "gradient-border",
      className
    )}
  >
    {children}
  </div>
);

const SectionHeading = ({
  badge,
  title,
  subtitle,
}: {
  badge: string;
  title: string;
  subtitle?: string;
}) => {
  const ref = useRef<HTMLDivElement>(null);
  useScrollReveal(ref, { children: true, stagger: 0.12 });
  return (
    <div ref={ref} className="text-center mb-16 md:mb-20 max-w-3xl mx-auto">
      <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full mb-6 text-sm font-semibold" style={{ background: "var(--badge-bg)", color: "var(--badge-text)", border: "1px solid var(--badge-border)" }}>
        <Sparkles size={14} />
        {badge}
      </div>
      <h2
        className="text-3xl md:text-5xl lg:text-6xl font-bold font-display leading-tight mb-6"
        style={{ color: "var(--text-primary)" }}
      >
        {title}
      </h2>
      {subtitle && (
        <p
          className="text-lg md:text-xl leading-relaxed max-w-2xl mx-auto"
          style={{ color: "var(--text-secondary)" }}
        >
          {subtitle}
        </p>
      )}
    </div>
  );
};

const BlobBackground = ({ className }: { className?: string }) => (
  <div className={cn("absolute inset-0 overflow-hidden pointer-events-none", className)}>
    <div className="blob blob-purple w-[500px] h-[500px] -top-40 -right-40" />
    <div className="blob blob-pink w-[400px] h-[400px] top-1/2 -left-40" />
    <div className="blob blob-cyan w-[350px] h-[350px] -bottom-20 right-1/4" />
  </div>
);

/* ═══════════════════════════════════════════════════
   1. NAVBAR
   ═══════════════════════════════════════════════════ */

const NAV_LINKS = [
  { href: "#features", label: "المميزات" },
  { href: "#how-it-works", label: "كيف يعمل" },
  { href: "#showcase", label: "المعرض" },
  { href: "#pricing", label: "الأسعار" },
  { href: "#download", label: "التحميل" },
];

function Navbar({
  theme,
  onToggleTheme,
}: {
  theme: "dark" | "light";
  onToggleTheme: () => void;
}) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const navRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useLayoutEffect(() => {
    if (!navRef.current) return;
    const ctx = gsap.context(() => {
      gsap.from(navRef.current, {
        y: -60,
        opacity: 0,
        duration: 0.8,
        ease: "power3.out",
        delay: 0.2,
      });
    });
    return () => ctx.revert();
  }, []);

  return (
    <nav
      ref={navRef}
      className={cn(
        "fixed top-0 left-0 right-0 z-50 transition-all duration-500",
        scrolled
          ? "py-3 shadow-md"
          : "py-5"
      )}
      style={{
        background: scrolled ? "var(--nav-bg)" : "transparent",
        backdropFilter: scrolled ? "blur(20px)" : "none",
        WebkitBackdropFilter: scrolled ? "blur(20px)" : "none",
        borderBottom: scrolled ? "1px solid var(--nav-border)" : "none",
      }}
    >
      <div className="container mx-auto px-6 flex items-center justify-between">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-3 group">
          <div className="w-10 h-10 rounded-xl overflow-hidden border border-white/10 relative">
            <Image src="/logo.jpeg" alt="Aqvioo" fill className="object-cover" />
          </div>
          <span className="text-xl font-bold font-display tracking-[0.2em] uppercase" style={{ color: "var(--text-primary)" }}>
            Aqvioo
          </span>
        </Link>

        {/* Desktop Links */}
        <div className="hidden lg:flex items-center gap-8">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm font-medium transition-colors duration-300 hover:text-[#8B5CF6]"
              style={{ color: "var(--text-secondary)" }}
            >
              {link.label}
            </Link>
          ))}
        </div>

        {/* Actions */}
        <div className="flex items-center gap-3">
          <button
            onClick={onToggleTheme}
            className="theme-toggle"
            aria-label="تبديل الوضع"
          >
            {theme === "dark" ? <Sun size={18} /> : <Moon size={18} />}
          </button>

          <Link
            href="#download"
            className="hidden md:flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold transition-all duration-300 hover:scale-105"
            style={{
              background: "var(--btn-primary-bg)",
              color: "var(--btn-primary-text)",
            }}
          >
            <Download size={16} />
            حمّل الآن
          </Link>

          {/* Mobile menu toggle */}
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="lg:hidden theme-toggle"
            aria-label="القائمة"
          >
            {menuOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {menuOpen && (
        <div
          className="lg:hidden mt-3 mx-6 p-6 rounded-2xl glass"
          style={{ borderColor: "var(--glass-border)" }}
        >
          <div className="flex flex-col gap-4">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setMenuOpen(false)}
                className="text-base font-medium py-2 transition-colors hover:text-[#8B5CF6]"
                style={{ color: "var(--text-primary)" }}
              >
                {link.label}
              </Link>
            ))}
            <Link
              href="#download"
              onClick={() => setMenuOpen(false)}
              className="flex items-center justify-center gap-2 px-6 py-3 rounded-xl text-sm font-bold mt-2"
              style={{
                background: "var(--btn-primary-bg)",
                color: "var(--btn-primary-text)",
              }}
            >
              <Download size={16} />
              حمّل الآن
            </Link>
          </div>
        </div>
      )}
    </nav>
  );
}

/* ═══════════════════════════════════════════════════
   2. HERO
   ═══════════════════════════════════════════════════ */

function Hero() {
  const sectionRef = useRef<HTMLElement>(null);
  const titleRef = useRef<HTMLDivElement>(null);
  const subRef = useRef<HTMLDivElement>(null);
  const btnsRef = useRef<HTMLDivElement>(null);
  const phoneRef = useRef<HTMLDivElement>(null);

  useLayoutEffect(() => {
    const ctx = gsap.context(() => {
      const tl = gsap.timeline();

      tl.from(titleRef.current, {
        y: 80,
        opacity: 0,
        duration: 1.2,
        ease: "power4.out",
        delay: 0.6,
      })
        .from(
          subRef.current,
          { y: 40, opacity: 0, duration: 0.9, ease: "power3.out" },
          "-=0.6"
        )
        .from(
          btnsRef.current,
          {
            y: 30,
            opacity: 0,
            duration: 0.8,
            ease: "back.out(1.5)",
          },
          "-=0.4"
        )
        .from(
          phoneRef.current,
          {
            y: 120,
            opacity: 0,
            scale: 0.9,
            duration: 1.4,
            ease: "power4.out",
          },
          "-=1"
        );

      // Parallax on phone
      gsap.to(phoneRef.current, {
        y: -80,
        scrollTrigger: {
          trigger: sectionRef.current,
          start: "top top",
          end: "bottom top",
          scrub: 1.5,
        },
      });
    }, sectionRef);

    return () => ctx.revert();
  }, []);

  return (
    <section
      ref={sectionRef}
      className="relative min-h-screen flex items-center pt-28 pb-20 overflow-hidden"
    >
      <BlobBackground />

      {/* Hero aurora glow */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[800px] h-[400px] rounded-full opacity-20" style={{ background: "radial-gradient(ellipse, rgba(139,92,246,0.3), rgba(236,72,153,0.15), transparent 70%)" }} />

      <div className="container mx-auto px-6 relative z-10">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-20 items-center">
          {/* Text Content */}
          <div className="text-right lg:order-1">
            <div ref={titleRef}>
              <div
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full mb-8 text-xs font-semibold"
                style={{
                  background: "var(--badge-bg)",
                  color: "var(--badge-text)",
                  border: "1px solid var(--badge-border)",
                }}
              >
                <Zap size={12} />
                مدعوم بأحدث تقنيات الذكاء الاصطناعي
              </div>
              <h1 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black font-display leading-[1.1] mb-2">
                <span style={{ color: "var(--text-primary)" }}>حوّل خيالك</span>
                <br />
                <span className="text-gradient-iridescent">إلى واقع بصري</span>
                <br />
                <span style={{ color: "var(--text-primary)" }}>مذهل</span>
              </h1>
            </div>

            <div ref={subRef}>
              <p
                className="text-lg md:text-xl leading-relaxed mt-6 mb-10 max-w-lg mr-auto"
                style={{ color: "var(--text-secondary)" }}
              >
                أنشئ فيديوهات وصور احترافية من نص أو صورة باستخدام أحدث نماذج
                الذكاء الاصطناعي — في ثوانٍ معدودة.
              </p>
            </div>

            <div ref={btnsRef} className="flex flex-wrap gap-4 justify-start">
              <Link
                href="#download"
                className="flex items-center gap-3 px-8 py-4 rounded-2xl font-bold text-base transition-all duration-300 hover:scale-105 hover:shadow-lg"
                style={{
                  background: "var(--btn-primary-bg)",
                  color: "var(--btn-primary-text)",
                  boxShadow: "var(--shadow-glow)",
                }}
              >
                <Sparkles size={20} />
                ابدأ الإبداع
              </Link>
              <Link
                href="#how-it-works"
                className="flex items-center gap-3 px-8 py-4 rounded-2xl font-bold text-base transition-all duration-300 hover:scale-105"
                style={{
                  background: "var(--btn-secondary-bg)",
                  color: "var(--btn-secondary-text)",
                  border: "1px solid var(--btn-secondary-border)",
                }}
              >
                <Play size={18} />
                شاهد العرض
              </Link>
            </div>
          </div>

          {/* Phone Mockup */}
          <div
            ref={phoneRef}
            className="relative flex items-center justify-center lg:order-2"
          >
            {/* Glow behind phone */}
            <div className="absolute w-[400px] h-[400px] rounded-full" style={{ background: "radial-gradient(circle, rgba(139,92,246,0.15), transparent 70%)" }} />

            <div className="phone-mockup">
              <div className="phone-notch" />
              <div className="phone-screen">
                <Image
                  src="/app-screenshot.png"
                  alt="Aqvioo App"
                  fill
                  className="object-cover object-top"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   3. FEATURES
   ═══════════════════════════════════════════════════ */

const FEATURES = [
  {
    icon: Video,
    title: "نص إلى فيديو",
    desc: "حوّل الوصف النصي إلى فيديوهات سينمائية عالية الجودة بأحدث نماذج الذكاء الاصطناعي.",
    color: "#8B5CF6",
  },
  {
    icon: ImageIcon,
    title: "صورة إلى فيديو",
    desc: "ارفع صورتك وشاهدها تنبض بالحياة — تحريك ذكي بتقنيات متقدمة.",
    color: "#EC4899",
  },
  {
    icon: Wand2,
    title: "تحسين ذكي للوصف",
    desc: "محرك GPT يُحسّن أفكارك تلقائياً للحصول على أفضل نتيجة بصرية ممكنة.",
    color: "#06B6D4",
  },
  {
    icon: Mic,
    title: "تعليق صوتي احترافي",
    desc: "أصوات ذكور وإناث بـ 6 لهجات عربية — سعودي، مصري، إماراتي، لبناني، أردني، مغربي.",
    color: "#F59E0B",
  },
  {
    icon: Palette,
    title: "+15 أسلوب إبداعي",
    desc: "سينمائي، أنيميشن، نوار، خيال علمي، وثائقي، فنتازيا، ريترو، وأكثر.",
    color: "#10B981",
  },
  {
    icon: Ratio,
    title: "صيغ متعددة",
    desc: "16:9 لليوتيوب، 9:16 لتيك توك وريلز، 1:1 لإنستغرام — فيديو وصورة.",
    color: "#F43F5E",
  },
];

function Features() {
  const gridRef = useRef<HTMLDivElement>(null);

  useScrollReveal(gridRef, { children: true, stagger: 0.1, y: 50 });

  return (
    <section id="features" className="relative py-24 md:py-32 overflow-hidden">
      <BlobBackground />

      <div className="container mx-auto px-6 relative z-10">
        <SectionHeading
          badge="المميزات"
          title="كل ما تحتاجه للإبداع البصري"
          subtitle="أدوات ذكاء اصطناعي متكاملة لإنشاء محتوى مرئي احترافي بسهولة"
        />

        <div ref={gridRef} className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {FEATURES.map((f) => (
            <GlassCard key={f.title} className="p-8 group" gradient>
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center mb-6 transition-transform duration-500 group-hover:scale-110 group-hover:rotate-3"
                style={{
                  background: `${f.color}15`,
                  color: f.color,
                  border: `1px solid ${f.color}30`,
                }}
              >
                <f.icon size={22} />
              </div>
              <h3
                className="text-lg font-bold mb-3 text-right font-display"
                style={{ color: "var(--text-primary)" }}
              >
                {f.title}
              </h3>
              <p
                className="text-sm leading-relaxed text-right"
                style={{ color: "var(--text-secondary)" }}
              >
                {f.desc}
              </p>
            </GlassCard>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   4. HOW IT WORKS
   ═══════════════════════════════════════════════════ */

const STEPS = [
  {
    num: "01",
    title: "اكتب فكرتك",
    desc: "صِف فكرتك بالنص أو ارفع صورة — المحسّن الذكي يُعزز وصفك تلقائياً.",
    icon: Wand2,
  },
  {
    num: "02",
    title: "اختر الإعدادات",
    desc: "حدد الأسلوب، المدة، نسبة العرض، والتعليق الصوتي حسب منصتك المفضلة.",
    icon: Palette,
  },
  {
    num: "03",
    title: "شاهد السحر",
    desc: "الذكاء الاصطناعي يبدع محتواك — شارك أو حمّل مباشرة من التطبيق.",
    icon: Sparkles,
  },
];

function HowItWorks() {
  const stepsRef = useRef<HTMLDivElement>(null);

  useScrollReveal(stepsRef, { children: true, stagger: 0.2, y: 60 });

  return (
    <section
      id="how-it-works"
      className="relative py-24 md:py-32 overflow-hidden"
    >
      <div className="container mx-auto px-6 relative z-10">
        <SectionHeading
          badge="كيف يعمل"
          title="ثلاث خطوات فقط"
          subtitle="من الفكرة إلى الفيديو في ثوانٍ — بكل بساطة"
        />

        <div
          ref={stepsRef}
          className="grid md:grid-cols-3 gap-8 md:gap-6"
        >
          {STEPS.map((step, i) => (
            <div key={step.num} className="relative">
              <GlassCard className="p-8 md:p-10 text-center h-full" gradient>
                <div className="text-6xl font-black font-display text-gradient-iridescent mb-6 opacity-30">
                  {step.num}
                </div>
                <div
                  className="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6"
                  style={{
                    background: "var(--badge-bg)",
                    border: "1px solid var(--badge-border)",
                    color: "var(--badge-text)",
                  }}
                >
                  <step.icon size={28} />
                </div>
                <h3
                  className="text-xl font-bold mb-4 font-display"
                  style={{ color: "var(--text-primary)" }}
                >
                  {step.title}
                </h3>
                <p
                  className="text-sm leading-relaxed"
                  style={{ color: "var(--text-secondary)" }}
                >
                  {step.desc}
                </p>
              </GlassCard>
              {/* Connector arrow on desktop */}
              {i < STEPS.length - 1 && (
                <div className="hidden md:flex absolute top-1/2 -left-6 -translate-y-1/2 z-10">
                  <ChevronLeft
                    size={24}
                    style={{ color: "var(--text-muted)" }}
                  />
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   5. SHOWCASE / GALLERY
   ═══════════════════════════════════════════════════ */

const SHOWCASE_ITEMS = [
  {
    title: "سينمائي",
    subtitle: "Cinematic",
    img: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=800",
  },
  {
    title: "أنيميشن",
    subtitle: "Animation",
    img: "https://images.unsplash.com/photo-1633167606207-d840b5070fc2?auto=format&fit=crop&q=80&w=800",
  },
  {
    title: "خيال علمي",
    subtitle: "Sci-Fi",
    img: "https://images.unsplash.com/photo-1620712943543-bcc4628c6757?auto=format&fit=crop&q=80&w=800",
  },
  {
    title: "فنتازيا",
    subtitle: "Fantasy",
    img: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&q=80&w=800",
  },
  {
    title: "نوار",
    subtitle: "Noir",
    img: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&q=80&w=800",
  },
  {
    title: "حالم",
    subtitle: "Dreamlike",
    img: "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&q=80&w=800",
  },
];

function Showcase() {
  const gridRef = useRef<HTMLDivElement>(null);

  useScrollReveal(gridRef, {
    children: true,
    stagger: 0.12,
    scale: 0.92,
    y: 40,
  });

  return (
    <section id="showcase" className="relative py-24 md:py-32 overflow-hidden">
      <BlobBackground />

      <div className="container mx-auto px-6 relative z-10">
        <SectionHeading
          badge="المعرض"
          title="اكتشف الأساليب الإبداعية"
          subtitle="أكثر من 15 أسلوباً مختلفاً لتحويل أفكارك إلى محتوى بصري فريد"
        />

        <div
          ref={gridRef}
          className="grid grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6"
        >
          {SHOWCASE_ITEMS.map((item) => (
            <div
              key={item.title}
              className="showcase-item relative aspect-[3/4] rounded-3xl overflow-hidden group cursor-pointer"
              style={{ border: "1px solid var(--glass-border)" }}
            >
              <Image
                src={item.img}
                alt={item.title}
                fill
                className="object-cover transition-all duration-700 group-hover:scale-110 grayscale-[30%] group-hover:grayscale-0"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-60 group-hover:opacity-80 transition-opacity duration-500" />
              <div className="absolute bottom-0 left-0 right-0 p-5 md:p-6 translate-y-2 group-hover:translate-y-0 transition-transform duration-500">
                <div className="text-white font-bold text-lg md:text-xl font-display">
                  {item.title}
                </div>
                <div className="text-white/50 text-xs mt-1 font-display tracking-wider uppercase">
                  {item.subtitle} — Made with Aqvioo
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}


/* ═══════════════════════════════════════════════════
   7. PRICING
   ═══════════════════════════════════════════════════ */

const PRICING_TIERS = [
  {
    amount: 15,
    videos: "~3",
    images: "~7",
    badge: null,
    popular: false,
  },
  {
    amount: 30,
    videos: "~6",
    images: "~15",
    badge: "الأكثر شيوعاً",
    popular: true,
  },
  {
    amount: 50,
    videos: "~10",
    images: "~25",
    badge: null,
    popular: false,
  },
  {
    amount: 100,
    videos: "~20",
    images: "~50",
    badge: "أفضل قيمة",
    popular: false,
  },
];

const PAYMENT_METHODS = [
  "Apple Pay",
  "Visa",
  "Mastercard",
  "MADA",
  "STC Pay",
];

function Pricing() {
  const gridRef = useRef<HTMLDivElement>(null);

  useScrollReveal(gridRef, { children: true, stagger: 0.1, y: 50 });

  return (
    <section
      id="pricing"
      className="relative py-24 md:py-32 overflow-hidden"
    >
      <BlobBackground />

      <div className="container mx-auto px-6 relative z-10">
        <SectionHeading
          badge="الأسعار"
          title="رصيد يناسب إبداعك"
          subtitle="اشحن رصيدك واستمتع بتوليد محتوى بصري احترافي"
        />

        <div
          ref={gridRef}
          className="grid grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-16"
        >
          {PRICING_TIERS.map((tier) => (
            <GlassCard
              key={tier.amount}
              className={cn(
                "p-6 md:p-8 text-center relative",
                tier.popular && "pricing-popular"
              )}
              gradient={tier.popular}
            >
              {tier.badge && (
                <div
                  className="absolute -top-3 left-1/2 -translate-x-1/2 px-4 py-1 rounded-full text-[11px] font-bold whitespace-nowrap"
                  style={{
                    background: "var(--btn-primary-bg)",
                    color: "var(--btn-primary-text)",
                  }}
                >
                  {tier.badge}
                </div>
              )}
              <div
                className="text-4xl md:text-5xl font-black font-display mb-2 mt-2"
                style={{ color: "var(--text-primary)" }}
              >
                {tier.amount}
              </div>
              <div
                className="text-sm font-medium mb-6"
                style={{ color: "var(--text-tertiary)" }}
              >
                ريال سعودي
              </div>

              <div className="aurora-line mb-6" />

              <div className="space-y-3 text-sm mb-6">
                <div className="flex items-center justify-center gap-2" style={{ color: "var(--text-secondary)" }}>
                  <Video size={14} />
                  <span>{tier.videos} فيديو</span>
                </div>
                <div className="flex items-center justify-center gap-2" style={{ color: "var(--text-secondary)" }}>
                  <ImageIcon size={14} />
                  <span>{tier.images} صورة</span>
                </div>
              </div>

              <button
                className="w-full py-3 rounded-xl font-bold text-sm transition-all duration-300 hover:scale-105"
                style={{
                  background: tier.popular
                    ? "var(--btn-primary-bg)"
                    : "var(--btn-secondary-bg)",
                  color: tier.popular
                    ? "var(--btn-primary-text)"
                    : "var(--btn-secondary-text)",
                  border: tier.popular
                    ? "none"
                    : "1px solid var(--btn-secondary-border)",
                }}
              >
                اشحن الآن
              </button>
            </GlassCard>
          ))}
        </div>

        {/* Payment methods */}
        <div className="text-center">
          <p
            className="text-xs mb-4 flex items-center justify-center gap-2"
            style={{ color: "var(--text-muted)" }}
          >
            <Shield size={14} />
            دفع آمن عبر
          </p>
          <div className="flex flex-wrap items-center justify-center gap-4">
            {PAYMENT_METHODS.map((method) => (
              <div
                key={method}
                className="px-4 py-2 rounded-xl text-xs font-medium glass"
              >
                {method}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   8. STATS / SOCIAL PROOF
   ═══════════════════════════════════════════════════ */

const STATS = [
  { value: 5000, suffix: "+", label: "مستخدم نشط" },
  { value: 25000, suffix: "+", label: "فيديو تم إنشاؤه" },
  { value: 15, suffix: "+", label: "أسلوب إبداعي" },
  { value: 6, suffix: "", label: "لهجات عربية" },
];

function Stats() {
  const sectionRef = useRef<HTMLElement>(null);
  const countersRef = useRef<HTMLDivElement>(null);

  useLayoutEffect(() => {
    if (!countersRef.current) return;
    const ctx = gsap.context(() => {
      const counters =
        countersRef.current!.querySelectorAll("[data-count]");

      counters.forEach((counter) => {
        const target = parseInt(counter.getAttribute("data-count") || "0");
        const suffix = counter.getAttribute("data-suffix") || "";

        gsap.fromTo(
          { val: 0 },
          { val: target },
          {
            val: target,
            duration: 2.5,
            ease: "power2.out",
            scrollTrigger: {
              trigger: counter,
              start: "top 85%",
              once: true,
            },
            onUpdate: function () {
              const current = Math.round(this.targets()[0].val);
              if (current >= 1000) {
                counter.textContent =
                  (current / 1000).toFixed(current >= 10000 ? 0 : 1) + "K" + suffix;
              } else {
                counter.textContent = current + suffix;
              }
            },
          }
        );
      });
    }, sectionRef);

    return () => ctx.revert();
  }, []);

  return (
    <section
      ref={sectionRef}
      className="relative py-20 md:py-28 overflow-hidden"
    >
      <div className="container mx-auto px-6 relative z-10">
        <div
          ref={countersRef}
          className="grid grid-cols-2 lg:grid-cols-4 gap-6"
        >
          {STATS.map((stat) => (
            <GlassCard key={stat.label} className="p-8 text-center">
              <div
                className="text-4xl md:text-5xl font-black font-display mb-3 text-gradient-iridescent"
                data-count={stat.value}
                data-suffix={stat.suffix}
              >
                0
              </div>
              <div
                className="text-sm font-medium"
                style={{ color: "var(--text-secondary)" }}
              >
                {stat.label}
              </div>
            </GlassCard>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   9. DOWNLOAD CTA
   ═══════════════════════════════════════════════════ */

function DownloadCTA() {
  const sectionRef = useRef<HTMLElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);

  useScrollReveal(contentRef, { children: true, stagger: 0.15 });

  return (
    <section
      id="download"
      ref={sectionRef}
      className="relative py-24 md:py-32 overflow-hidden"
    >
      <BlobBackground />

      <div className="container mx-auto px-6 relative z-10">
        <div
          className="glass rounded-[32px] md:rounded-[40px] p-10 md:p-16 lg:p-20 text-center relative overflow-hidden"
          style={{
            borderColor: "var(--pricing-popular-border)",
            boxShadow: "var(--pricing-popular-glow)",
          }}
        >
          {/* Inner glow */}
          <div
            className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[300px] rounded-full opacity-30"
            style={{
              background:
                "radial-gradient(ellipse, rgba(139,92,246,0.2), transparent 70%)",
            }}
          />

          <div ref={contentRef} className="relative z-10">
            <div
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full mb-6 text-sm font-semibold"
              style={{
                background: "var(--badge-bg)",
                color: "var(--badge-text)",
                border: "1px solid var(--badge-border)",
              }}
            >
              <Smartphone size={14} />
              متاح الآن
            </div>

            <h2
              className="text-3xl md:text-5xl lg:text-6xl font-black font-display mb-6"
              style={{ color: "var(--text-primary)" }}
            >
              ابدأ رحلتك الإبداعية <span className="text-gradient-iridescent">الآن</span>
            </h2>
            <p
              className="text-lg md:text-xl mb-10 max-w-2xl mx-auto"
              style={{ color: "var(--text-secondary)" }}
            >
              حمّل أقفيو مجاناً وابدأ بإنشاء محتوى بصري مذهل بالذكاء
              الاصطناعي
            </p>

            <div className="flex flex-col sm:flex-row justify-center gap-4">
              {/* App Store */}
              <Link
                href="#"
                className="flex items-center justify-center gap-3 px-8 py-4 rounded-2xl font-bold transition-all duration-300 hover:scale-105"
                style={{
                  background: "var(--text-primary)",
                  color: "var(--bg-primary)",
                }}
              >
                <svg
                  className="w-6 h-6"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.23-3.14-2.47-1.7-2.45-3-7-1.18-10.16.9-1.55 2.54-2.51 4.31-2.54 1.29-.01 2.41.84 3.19.84.78 0 2.14-.84 3.59-.81 1.23.06 2.34.49 3.14 1.27-2.61 1.55-2.18 5.76.5 6.94-.48 1.44-1.12 2.87-1.8 3.87zm-4.32-15.6c.67-.84.97-1.92.83-2.9-1.52.06-3 .92-3.83 1.94-.78.96-1.13 2.15-.89 2.97 1.69.13 3.19-1.17 3.89-2.01z" />
                </svg>
                App Store
              </Link>
              {/* Google Play */}
              <Link
                href="#"
                className="flex items-center justify-center gap-3 px-8 py-4 rounded-2xl font-bold transition-all duration-300 hover:scale-105"
                style={{
                  background: "var(--btn-secondary-bg)",
                  color: "var(--btn-secondary-text)",
                  border: "1px solid var(--btn-secondary-border)",
                }}
              >
                <svg
                  className="w-6 h-6"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z" />
                </svg>
                Google Play
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════
   10. FOOTER
   ═══════════════════════════════════════════════════ */

const FOOTER_LINKS = [
  { href: "/privacy", label: "سياسة الخصوصية" },
  { href: "/terms", label: "الشروط والأحكام" },
  { href: "/copyright", label: "حقوق النشر" },
  { href: "/support", label: "الدعم الفني" },
];

function Footer() {
  return (
    <footer
      className="relative py-16 md:py-20"
      style={{
        background: "var(--footer-bg)",
        borderTop: "1px solid var(--footer-border)",
      }}
    >
      <div className="container mx-auto px-6">
        <div className="flex flex-col md:flex-row justify-between items-center gap-10 mb-12">
          {/* Logo */}
          <div className="flex flex-col items-center md:items-start gap-4">
            <Link href="/" className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl overflow-hidden border relative" style={{ borderColor: "var(--glass-border)" }}>
                <Image
                  src="/logo.jpeg"
                  alt="Aqvioo"
                  fill
                  className="object-cover"
                />
              </div>
              <span
                className="text-lg font-bold font-display tracking-widest uppercase"
                style={{ color: "var(--text-primary)" }}
              >
                Aqvioo
              </span>
            </Link>
            <p
              className="text-sm max-w-xs text-center md:text-right leading-relaxed"
              style={{ color: "var(--text-tertiary)" }}
            >
              الجيل القادم من محركات الإبداع البصري بالذكاء الاصطناعي.
            </p>
          </div>

          {/* Links */}
          <div className="flex flex-wrap gap-6 justify-center text-sm">
            {FOOTER_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="transition-colors hover:text-[#8B5CF6]"
                style={{ color: "var(--text-secondary)" }}
              >
                {link.label}
              </Link>
            ))}
          </div>

          {/* Contact */}
          <div className="flex items-center gap-2 text-sm" style={{ color: "var(--text-tertiary)" }}>
            <Mail size={14} />
            <a
              href="mailto:Aqvioo@outlook.sa"
              className="hover:text-[#8B5CF6] transition-colors"
            >
              Aqvioo@outlook.sa
            </a>
          </div>
        </div>

        {/* Aurora separator */}
        <div className="aurora-line mb-8" />

        <div
          className="text-center text-xs"
          style={{ color: "var(--text-muted)" }}
        >
          &copy; {new Date().getFullYear()} يوسف الغامدي. جميع الحقوق
          محفوظة.
        </div>
      </div>
    </footer>
  );
}

/* ═══════════════════════════════════════════════════
   PAGE
   ═══════════════════════════════════════════════════ */

export default function Home() {
  const { theme, toggle } = useTheme();
  useLenis();

  return (
    <main className="min-h-screen overflow-hidden">
      <Navbar theme={theme} onToggleTheme={toggle} />
      <Hero />
      <div className="aurora-line" />
      <Features />
      <HowItWorks />
      <div className="aurora-line" />
      <Showcase />
      <div className="aurora-line" />
      <Pricing />
      <Stats />
      <DownloadCTA />
      <Footer />
    </main>
  );
}
