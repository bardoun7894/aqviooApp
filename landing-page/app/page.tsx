"use client";

import { useState, useEffect, useRef } from "react";
import Link from "next/link";
import Image from "next/image";
import { motion, useScroll, useTransform, useInView } from "framer-motion";
import {
  Sparkles,
  Wand2,
  Video,
  Image as ImageIcon,
  Zap,
  Download,
  Menu,
  X,
  Play,
  CheckCircle2,
  Star,
  ArrowLeft,
  Smartphone,
  Globe,
  Shield,
} from "lucide-react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// --- Animated Background Components ---

const FloatingOrb = ({
  className,
  delay = 0,
  duration = 20
}: {
  className?: string;
  delay?: number;
  duration?: number;
}) => (
  <motion.div
    className={cn(
      "absolute rounded-full blur-3xl opacity-30",
      className
    )}
    animate={{
      y: [0, -30, 0],
      x: [0, 15, 0],
      scale: [1, 1.1, 1],
    }}
    transition={{
      duration,
      repeat: Infinity,
      delay,
      ease: "easeInOut",
    }}
  />
);

const GridPattern = () => (
  <div className="absolute inset-0 overflow-hidden pointer-events-none">
    <div
      className="absolute inset-0 opacity-[0.02]"
      style={{
        backgroundImage: `linear-gradient(rgba(139, 92, 246, 0.3) 1px, transparent 1px),
                          linear-gradient(90deg, rgba(139, 92, 246, 0.3) 1px, transparent 1px)`,
        backgroundSize: '60px 60px',
      }}
    />
  </div>
);

const AnimatedGradient = () => (
  <div className="absolute inset-0 overflow-hidden pointer-events-none">
    <motion.div
      className="absolute -top-1/2 -right-1/2 w-full h-full bg-gradient-radial from-purple-600/20 via-transparent to-transparent"
      animate={{
        rotate: [0, 360],
      }}
      transition={{
        duration: 60,
        repeat: Infinity,
        ease: "linear",
      }}
    />
  </div>
);

// --- Reusable Components ---

const GlassCard = ({
  children,
  className,
  hover = true
}: {
  children: React.ReactNode;
  className?: string;
  hover?: boolean;
}) => (
  <div className={cn(
    "relative backdrop-blur-xl bg-white/[0.02] border border-white/[0.05] rounded-3xl overflow-hidden",
    "before:absolute before:inset-0 before:bg-gradient-to-br before:from-white/[0.08] before:to-transparent before:pointer-events-none",
    hover && "hover:border-purple-500/30 hover:bg-white/[0.04] transition-all duration-500",
    className
  )}>
    {children}
  </div>
);

const ShimmerButton = ({
  children,
  className,
  variant = "primary"
}: {
  children: React.ReactNode;
  className?: string;
  variant?: "primary" | "secondary";
}) => (
  <button className={cn(
    "relative group overflow-hidden rounded-2xl font-bold transition-all duration-300",
    variant === "primary"
      ? "bg-gradient-to-r from-purple-600 to-purple-500 text-white shadow-xl shadow-purple-500/25 hover:shadow-purple-500/40 hover:scale-[1.02]"
      : "bg-white/5 text-white border border-white/10 hover:bg-white/10 hover:border-white/20",
    className
  )}>
    <span className="relative z-10 flex items-center justify-center gap-3">
      {children}
    </span>
    {variant === "primary" && (
      <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-700" />
    )}
  </button>
);

// --- Section Animation Wrapper ---

const AnimatedSection = ({
  children,
  className
}: {
  children: React.ReactNode;
  className?: string;
}) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 60 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 60 }}
      transition={{ duration: 0.8, ease: "easeOut" }}
      className={className}
    >
      {children}
    </motion.div>
  );
};

// --- Main Components ---

const Navbar = () => {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <nav className={cn(
      "fixed top-0 left-0 right-0 z-50 transition-all duration-500",
      scrolled
        ? "bg-[#0F172A]/80 backdrop-blur-xl border-b border-white/5 py-4"
        : "bg-transparent py-6"
    )}>
      <div className="container mx-auto px-6 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-3 group">
          <motion.div
            className="w-12 h-12 relative rounded-xl overflow-hidden shadow-lg border border-white/10 group-hover:border-purple-500/50 transition-colors"
            whileHover={{ scale: 1.05, rotate: 5 }}
            transition={{ type: "spring", stiffness: 400 }}
          >
            <Image
              src="/logo.jpeg"
              alt="Aqvioo Logo"
              fill
              className="object-cover"
            />
          </motion.div>
          <span className="text-2xl font-bold text-white tracking-tight">
            أقفيو
          </span>
        </Link>

        {/* Desktop Menu */}
        <div className="hidden md:flex items-center gap-8">
          {[
            { href: "#features", label: "المميزات" },
            { href: "#showcase", label: "المعرض" },
            { href: "#install", label: "التحميل" },
          ].map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="relative text-slate-300 hover:text-white transition-colors text-sm font-medium group"
            >
              {item.label}
              <span className="absolute -bottom-1 right-0 w-0 h-0.5 bg-purple-500 group-hover:w-full transition-all duration-300" />
            </Link>
          ))}

          <Link href="#install">
            <ShimmerButton className="px-6 py-2.5 text-sm">
              <Download size={16} />
              حمل التطبيق
            </ShimmerButton>
          </Link>
        </div>

        {/* Mobile Menu Toggle */}
        <motion.button
          className="md:hidden text-white p-2 rounded-xl hover:bg-white/10 transition-colors"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          whileTap={{ scale: 0.95 }}
        >
          {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
        </motion.button>
      </div>

      {/* Mobile Menu */}
      <motion.div
        initial={false}
        animate={mobileMenuOpen ? { height: "auto", opacity: 1 } : { height: 0, opacity: 0 }}
        className="md:hidden overflow-hidden"
      >
        <div className="bg-[#0F172A]/95 backdrop-blur-xl border-t border-white/5 p-6 flex flex-col gap-4">
          <Link href="#features" className="text-slate-300 hover:text-white py-3 text-lg" onClick={() => setMobileMenuOpen(false)}>المميزات</Link>
          <Link href="#showcase" className="text-slate-300 hover:text-white py-3 text-lg" onClick={() => setMobileMenuOpen(false)}>المعرض</Link>
          <Link href="#install" className="w-full py-4 rounded-2xl bg-gradient-to-r from-purple-600 to-purple-500 text-white font-bold text-center text-lg" onClick={() => setMobileMenuOpen(false)}>
            حمل التطبيق
          </Link>
        </div>
      </motion.div>
    </nav>
  );
};

const Hero = () => {
  const containerRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end start"]
  });

  const y = useTransform(scrollYProgress, [0, 1], [0, 200]);
  const opacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);

  return (
    <section ref={containerRef} className="relative min-h-screen flex items-center pt-32 pb-20 overflow-hidden bg-[#0F172A]">
      {/* Animated Background Elements */}
      <FloatingOrb className="w-[600px] h-[600px] bg-purple-600 -top-40 -right-40" delay={0} />
      <FloatingOrb className="w-[400px] h-[400px] bg-blue-600 bottom-20 -left-20" delay={2} />
      <FloatingOrb className="w-[300px] h-[300px] bg-pink-600 top-1/3 left-1/4" delay={4} />
      <GridPattern />
      <AnimatedGradient />

      <div className="container mx-auto px-6 grid lg:grid-cols-2 gap-16 items-center relative z-10">
        <motion.div
          style={{ y, opacity }}
          className="text-right lg:order-1"
        >
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-300 text-sm font-medium mb-8"
          >
            <Sparkles size={16} className="animate-pulse" />
            <span>مدعوم بأحدث تقنيات الذكاء الاصطناعي</span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.1 }}
            className="text-5xl md:text-7xl font-bold leading-tight mb-8"
          >
            <span className="text-white">حول خيالك</span> <br />
            <span className="bg-gradient-to-l from-purple-400 via-pink-400 to-purple-600 bg-clip-text text-transparent">
              إلى واقع ملموس
            </span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-xl text-slate-400 mb-10 max-w-lg leading-relaxed mr-auto md:ml-0 ml-auto"
          >
            أنتج فيديوهات سينمائية وصوراً مذهلة في ثوانٍ. القوة الكاملة للذكاء الاصطناعي الآن في جيبك.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="flex flex-col sm:flex-row gap-4 justify-start"
          >
            <Link href="#install">
              <ShimmerButton className="px-8 py-4 text-lg w-full sm:w-auto">
                <span>حمل التطبيق الآن</span>
                <Download size={20} />
              </ShimmerButton>
            </Link>
            <Link href="#showcase">
              <ShimmerButton variant="secondary" className="px-8 py-4 text-lg w-full sm:w-auto">
                <span>شاهد المعرض</span>
                <Play size={20} />
              </ShimmerButton>
            </Link>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="mt-12 flex flex-wrap items-center gap-6 text-sm text-slate-400 justify-start"
          >
            {[
              { icon: CheckCircle2, text: "بدون اشتراك شهري" },
              { icon: Globe, text: "يدعم العربية" },
              { icon: Shield, text: "آمن وموثوق" },
            ].map((item, i) => (
              <div key={i} className="flex items-center gap-2">
                <item.icon className="text-purple-500" size={18} />
                <span>{item.text}</span>
              </div>
            ))}
          </motion.div>
        </motion.div>

        <motion.div
          className="relative lg:h-[800px] flex items-center justify-center lg:order-2"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 1, delay: 0.3 }}
        >
          {/* Glow Effect */}
          <div className="absolute w-[400px] h-[400px] bg-purple-600/30 rounded-full blur-[100px] animate-pulse" />

          {/* Phone Mockup */}
          <motion.div
            className="relative w-[300px] sm:w-[340px] h-[640px] sm:h-[700px] bg-gradient-to-b from-slate-800 to-slate-900 rounded-[48px] border-4 border-slate-700 shadow-2xl shadow-purple-900/30 overflow-hidden"
            whileHover={{ scale: 1.02, rotateY: -5 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            {/* Notch */}
            <div className="absolute top-4 left-1/2 -translate-x-1/2 w-24 h-6 bg-black rounded-full z-20" />

            {/* Screen Content */}
            <div className="absolute inset-2 rounded-[40px] bg-slate-950 overflow-hidden">
              {/* UI Header */}
              <div className="absolute top-0 left-0 right-0 h-28 p-6 flex justify-between items-end bg-gradient-to-b from-slate-900 via-slate-900/80 to-transparent z-10" dir="rtl">
                <Menu className="text-white/70" size={20} />
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 rounded-lg bg-purple-600 flex items-center justify-center">
                    <Sparkles size={12} className="text-white" />
                  </div>
                  <span className="text-white font-bold text-sm">أقفيو</span>
                </div>
              </div>

              {/* Feed */}
              <div className="absolute inset-0 pt-28 px-3 pb-24 overflow-hidden space-y-3">
                {/* Generated Item 1 */}
                <motion.div
                  className="aspect-[4/5] bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl overflow-hidden relative group"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.8 }}
                >
                  <div className="absolute inset-0 bg-gradient-to-br from-purple-600/20 via-transparent to-pink-600/20" />
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="w-16 h-16 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center">
                      <Play className="text-white" size={24} />
                    </div>
                  </div>
                  {/* Overlay Label */}
                  <div className="absolute bottom-3 right-3 left-3 flex justify-between items-center">
                    <div className="bg-black/60 px-3 py-1.5 rounded-full backdrop-blur-sm">
                      <span className="text-xs text-white font-medium">سايبربانك</span>
                    </div>
                    <div className="flex items-center gap-1 bg-black/60 px-2 py-1 rounded-full backdrop-blur-sm">
                      <Star className="text-yellow-400" size={12} fill="currentColor" />
                      <span className="text-xs text-white">4.9</span>
                    </div>
                  </div>
                </motion.div>
                {/* Generated Item 2 - Partial */}
                <motion.div
                  className="aspect-[4/5] bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 0.5, y: 0 }}
                  transition={{ delay: 1 }}
                />
              </div>

              {/* Bottom Nav */}
              <div className="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-slate-950 to-transparent flex items-center justify-center gap-8 px-6 z-20">
                <div className="w-10 h-10 rounded-xl bg-slate-800/50 flex items-center justify-center text-slate-400">
                  <ImageIcon size={18} />
                </div>
                <motion.div
                  className="w-14 h-14 bg-gradient-to-br from-purple-500 to-purple-700 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-purple-500/50"
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <Wand2 size={22} />
                </motion.div>
                <div className="w-10 h-10 rounded-xl bg-slate-800/50 flex items-center justify-center text-slate-400">
                  <Video size={18} />
                </div>
              </div>
            </div>
          </motion.div>

          {/* Floating Elements */}
          <motion.div
            className="absolute -top-10 -right-10 w-20 h-20"
            animate={{ y: [0, -10, 0], rotate: [0, 5, 0] }}
            transition={{ duration: 4, repeat: Infinity }}
          >
            <GlassCard className="w-full h-full flex items-center justify-center" hover={false}>
              <Sparkles className="text-purple-400" size={28} />
            </GlassCard>
          </motion.div>

          <motion.div
            className="absolute -bottom-5 -left-5 w-16 h-16"
            animate={{ y: [0, 10, 0], rotate: [0, -5, 0] }}
            transition={{ duration: 3, repeat: Infinity, delay: 1 }}
          >
            <GlassCard className="w-full h-full flex items-center justify-center" hover={false}>
              <Zap className="text-yellow-400" size={24} />
            </GlassCard>
          </motion.div>
        </motion.div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        className="absolute bottom-10 left-1/2 -translate-x-1/2"
        animate={{ y: [0, 10, 0] }}
        transition={{ duration: 2, repeat: Infinity }}
      >
        <div className="w-6 h-10 rounded-full border-2 border-white/20 flex items-start justify-center p-2">
          <motion.div
            className="w-1.5 h-1.5 rounded-full bg-white/50"
            animate={{ y: [0, 12, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
          />
        </div>
      </motion.div>
    </section>
  );
};

interface FeatureCardProps {
  icon: React.ElementType;
  title: string;
  description: string;
  index: number;
}

const FeatureCard = ({ icon: Icon, title, description, index }: FeatureCardProps) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-50px" });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 40 }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
    >
      <GlassCard className="p-8 h-full group cursor-pointer">
        <div className="relative">
          {/* Icon */}
          <motion.div
            className="w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500/20 to-purple-600/10 flex items-center justify-center mb-6 ms-auto text-purple-400 group-hover:from-purple-500 group-hover:to-purple-700 group-hover:text-white transition-all duration-500"
            whileHover={{ scale: 1.1, rotate: 5 }}
          >
            <Icon size={28} />
          </motion.div>

          <h3 className="text-xl font-bold mb-3 text-white text-right group-hover:text-purple-300 transition-colors">{title}</h3>
          <p className="text-slate-400 leading-relaxed text-sm text-right group-hover:text-slate-300 transition-colors">
            {description}
          </p>

          {/* Hover Arrow */}
          <motion.div
            className="absolute bottom-0 left-0 opacity-0 group-hover:opacity-100 transition-opacity"
            initial={{ x: 10 }}
            whileHover={{ x: 0 }}
          >
            <ArrowLeft className="text-purple-400" size={20} />
          </motion.div>
        </div>
      </GlassCard>
    </motion.div>
  );
};

const Features = () => {
  const features = [
    {
      icon: Video,
      title: "نصوص إلى فيديو",
      description: "حول الوصف النصي البسيط إلى فيديوهات عالية الجودة وانسيابية باستخدام أحدث نماذج الذكاء الاصطناعي.",
    },
    {
      icon: ImageIcon,
      title: "صور إلى فيديو",
      description: "اجعل صورك الثابتة تنبض بالحياة مع تقنيات التحريك المتقدمة والواقعية.",
    },
    {
      icon: Wand2,
      title: "المحسن الذكي",
      description: "ميزة 'تحسين الوصف' تقوم بتوسيع أفكارك البسيطة للحصول على أفضل النتائج الإبداعية.",
    },
    {
      icon: Zap,
      title: "سرعة فائقة",
      description: "استمتع بتجربة إبداعية فورية مع أسرع خوادم المعالجة في العالم.",
    }
  ];

  return (
    <section id="features" className="py-32 bg-[#0B1221] relative overflow-hidden">
      <FloatingOrb className="w-[500px] h-[500px] bg-purple-600 -top-60 -left-60" delay={1} />
      <GridPattern />

      <div className="container mx-auto px-6 relative z-10">
        <AnimatedSection>
          <div className="text-center mb-20">
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5 }}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-300 text-sm font-medium mb-6"
            >
              <Sparkles size={16} />
              <span>مميزات متقدمة</span>
            </motion.div>
            <h2 className="text-3xl md:text-5xl font-bold mb-6 text-white">
              كل ما تحتاجه للإبداع
            </h2>
            <p className="text-slate-400 max-w-2xl mx-auto text-lg">
              أدوات احترافية صممت لتكون سهلة الاستخدام للجميع.
            </p>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((f, i) => (
            <FeatureCard key={i} {...f} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
};

const Showcase = () => {
  const showcaseItems = [
    { gradient: "from-purple-600 via-pink-500 to-orange-400", label: "خيال علمي" },
    { gradient: "from-cyan-500 via-blue-500 to-purple-600", label: "مستقبلي" },
    { gradient: "from-green-500 via-teal-500 to-cyan-500", label: "طبيعة" },
  ];

  return (
    <section id="showcase" className="py-32 bg-[#0F172A] relative overflow-hidden">
      <FloatingOrb className="w-[400px] h-[400px] bg-blue-600 top-20 -right-40" delay={2} />
      <GridPattern />

      <div className="container mx-auto px-6 relative z-10">
        <AnimatedSection>
          <div className="flex flex-col md:flex-row items-center justify-between mb-16 gap-6">
            <div className="text-right w-full">
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5 }}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-300 text-sm font-medium mb-6"
              >
                <Star size={16} />
                <span>إبداعات المستخدمين</span>
              </motion.div>
              <h2 className="text-3xl md:text-5xl font-bold text-white mb-4">معرض الأعمال</h2>
              <p className="text-slate-400 text-lg">نماذج مما قام مستخدمونا بإنشائه باستخدام التطبيق</p>
            </div>
          </div>
        </AnimatedSection>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {showcaseItems.map((item, i) => (
            <motion.div
              key={i}
              className="group relative aspect-[9/16] rounded-3xl overflow-hidden cursor-pointer"
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: i * 0.15 }}
              whileHover={{ scale: 1.02 }}
            >
              <GlassCard className="h-full w-full" hover={false}>
                {/* Animated Gradient Background */}
                <div className={cn(
                  "absolute inset-0 bg-gradient-to-br opacity-20 group-hover:opacity-40 transition-opacity duration-500",
                  item.gradient
                )} />

                {/* Content */}
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <motion.div
                    className="w-20 h-20 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center mb-4 group-hover:scale-110 transition-transform duration-300"
                    whileHover={{ scale: 1.2 }}
                  >
                    <Play size={32} className="text-white ml-1" />
                  </motion.div>
                  <span className="text-white/60 text-sm font-medium">{item.label}</span>
                </div>

                {/* Bottom Overlay */}
                <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1">
                      <Star className="text-yellow-400" size={14} fill="currentColor" />
                      <span className="text-white text-sm">4.9</span>
                    </div>
                    <span className="text-white/80 text-sm">اضغط للمشاهدة</span>
                  </div>
                </div>
              </GlassCard>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

const InstallSection = () => {
  return (
    <section id="install" className="py-32 bg-[#0B1221] relative overflow-hidden">
      <FloatingOrb className="w-[600px] h-[600px] bg-purple-600 -bottom-40 left-1/2 -translate-x-1/2" delay={0} />

      <div className="container mx-auto px-6 max-w-5xl relative z-10">
        <AnimatedSection>
          <GlassCard className="p-12 md:p-20 text-center" hover={false}>
            {/* Decorative Elements */}
            <div className="absolute inset-0 bg-gradient-to-br from-purple-600/20 via-transparent to-pink-600/20 pointer-events-none" />
            <div className="absolute top-0 right-0 w-40 h-40 bg-purple-500/20 rounded-full blur-3xl" />
            <div className="absolute bottom-0 left-0 w-40 h-40 bg-pink-500/20 rounded-full blur-3xl" />

            <div className="relative z-10">
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5 }}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 text-white text-sm font-medium mb-8"
              >
                <Smartphone size={16} />
                <span>متاح الآن على iOS و Android</span>
              </motion.div>

              <h2 className="text-3xl md:text-5xl font-bold mb-8 text-white">
                انطلق في رحلة الإبداع
              </h2>
              <p className="text-lg text-slate-300 mb-12 max-w-2xl mx-auto">
                حمل التطبيق اليوم وابدأ بصناعة محتوى لا ينسى. متاح مجاناً مع رصيد ترحيبي.
              </p>

              <div className="flex flex-col md:flex-row justify-center gap-6">
                <motion.div whileHover={{ scale: 1.05, y: -5 }} whileTap={{ scale: 0.98 }}>
                  <Link href="https://apps.apple.com" className="flex items-center gap-4 bg-white hover:bg-slate-100 text-slate-900 px-8 py-5 rounded-2xl transition-all shadow-xl text-right justify-center group">
                    <div className="text-black group-hover:scale-110 transition-transform">
                      <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.23-3.14-2.47-1.7-2.45-3-7-1.18-10.16.9-1.55 2.54-2.51 4.31-2.54 1.29-.01 2.41.84 3.19.84.78 0 2.14-.84 3.59-.81 1.23.06 2.34.49 3.14 1.27-2.61 1.55-2.18 5.76.5 6.94-.48 1.44-1.12 2.87-1.8 3.87zm-4.32-15.6c.67-.84.97-1.92.83-2.9-1.52.06-3 .92-3.83 1.94-.78.96-1.13 2.15-.89 2.97 1.69.13 3.19-1.17 3.89-2.01z" /></svg>
                    </div>
                    <div>
                      <div className="text-xs text-slate-500">حمله الآن من</div>
                      <div className="text-xl font-bold">App Store</div>
                    </div>
                  </Link>
                </motion.div>

                <motion.div whileHover={{ scale: 1.05, y: -5 }} whileTap={{ scale: 0.98 }}>
                  <Link href="https://play.google.com" className="flex items-center gap-4 bg-slate-900 hover:bg-slate-800 text-white px-8 py-5 rounded-2xl transition-all shadow-xl text-right justify-center border border-white/10 group">
                    <div className="group-hover:scale-110 transition-transform">
                      <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor"><path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z" /></svg>
                    </div>
                    <div>
                      <div className="text-xs text-slate-400">احصل عليه من</div>
                      <div className="text-xl font-bold">Google Play</div>
                    </div>
                  </Link>
                </motion.div>
              </div>
            </div>
          </GlassCard>
        </AnimatedSection>
      </div>
    </section>
  );
}

const Footer = () => {
  return (
    <footer className="bg-[#050914] border-t border-white/5 pt-20 pb-10 relative">
      <GridPattern />

      <div className="container mx-auto px-6 relative z-10">
        <div className="grid md:grid-cols-4 gap-12 mb-16 px-4">
          <div className="col-span-1 md:col-span-2 text-right">
            <Link href="/" className="flex items-center gap-3 mb-6 justify-end md:justify-start">
              <motion.div
                className="w-12 h-12 relative rounded-xl overflow-hidden border border-white/10"
                whileHover={{ scale: 1.05, rotate: 5 }}
              >
                <Image src="/logo.jpeg" alt="Logo" fill className="object-cover" />
              </motion.div>
              <span className="text-xl font-bold text-white">أقفيو</span>
            </Link>
            <p className="text-slate-400 max-w-sm mb-6 mr-auto md:ml-0 md:mr-0">
              الجناح الإبداعي المتكامل للذكاء الاصطناعي. حول أفكارك إلى واقع بصري مذهل.
            </p>
            <div className="flex gap-3 justify-end md:justify-start">
              {[Sparkles, Video, ImageIcon].map((Icon, i) => (
                <motion.div
                  key={i}
                  className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center text-slate-400 hover:text-purple-400 hover:bg-white/10 transition-colors cursor-pointer"
                  whileHover={{ scale: 1.1, y: -2 }}
                >
                  <Icon size={18} />
                </motion.div>
              ))}
            </div>
          </div>

          <div className="text-right">
            <h4 className="text-white font-semibold mb-4">روابط سريعة</h4>
            <ul className="space-y-3 text-slate-400 text-sm">
              {[
                { href: "#features", label: "المميزات" },
                { href: "#showcase", label: "المعرض" },
                { href: "#install", label: "التحميل" },
              ].map((item) => (
                <li key={item.href}>
                  <Link href={item.href} className="hover:text-purple-400 transition-colors flex items-center gap-2 justify-end group">
                    <span>{item.label}</span>
                    <ArrowLeft size={14} className="opacity-0 group-hover:opacity-100 transition-opacity" />
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div className="text-right">
            <h4 className="text-white font-semibold mb-4">قانوني</h4>
            <ul className="space-y-3 text-slate-400 text-sm">
              {[
                { href: "/privacy", label: "سياسة الخصوصية" },
                { href: "/terms", label: "الشروط والأحكام" },
                { href: "/support", label: "الدعم الفني" },
              ].map((item) => (
                <li key={item.href}>
                  <Link href={item.href} className="hover:text-purple-400 transition-colors flex items-center gap-2 justify-end group">
                    <span>{item.label}</span>
                    <ArrowLeft size={14} className="opacity-0 group-hover:opacity-100 transition-opacity" />
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="border-t border-white/5 pt-8 flex flex-col md:flex-row-reverse items-center justify-between gap-4">
          <p className="text-slate-500 text-sm">© 2024 أقفيو للذكاء الاصطناعي. جميع الحقوق محفوظة.</p>
          <div className="flex items-center gap-2 text-slate-500 text-sm">
            <span>صنع بـ</span>
            <motion.span
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 1, repeat: Infinity }}
              className="text-red-500"
            >
              ❤️
            </motion.span>
            <span>في السعودية</span>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default function Home() {
  return (
    <main className="min-h-screen bg-[#0F172A] text-white selection:bg-purple-500/30 selection:text-white overflow-x-hidden">
      <Navbar />
      <Hero />
      <Features />
      <Showcase />
      <InstallSection />
      <Footer />
    </main>
  );
}
