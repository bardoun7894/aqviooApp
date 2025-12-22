"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { motion } from "framer-motion";
import {
  Sparkles,
  Wand2,
  Video,
  Image as ImageIcon,
  Zap,
  Download,
  Menu,
  X,
  ChevronLeft,
  Play,
  CheckCircle2,
  Mail,
  Shield,
  FileText
} from "lucide-react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// --- Components ---

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
      "fixed top-0 left-0 right-0 z-50 transition-all duration-300 border-b border-transparent",
      scrolled ? "bg-[#0F172A]/90 backdrop-blur-md border-white/5 py-4" : "bg-transparent py-6"
    )}>
      <div className="container mx-auto px-6 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-3 group">
          <div className="w-12 h-12 relative rounded-xl overflow-hidden shadow-lg border border-white/10">
            <Image
              src="/logo.jpeg"
              alt="Aqvioo Logo"
              fill
              className="object-cover"
            />
          </div>
          <span className="text-2xl font-bold text-white tracking-tight">
            أقفيو
          </span>
        </Link>

        {/* Desktop Menu */}
        <div className="hidden md:flex items-center gap-8">
          <Link href="#features" className="text-slate-300 hover:text-white transition-colors text-sm font-medium">المميزات</Link>
          <Link href="#showcase" className="text-slate-300 hover:text-white transition-colors text-sm font-medium">المعرض</Link>
          <Link href="#install" className="text-slate-300 hover:text-white transition-colors text-sm font-medium">التحميل</Link>

          <Link href="#install" className="bg-white text-slate-900 px-6 py-2.5 rounded-full font-bold hover:bg-slate-100 transition-colors flex items-center gap-2 text-sm">
            <Download size={16} />
            حمل التطبيق
          </Link>
        </div>

        {/* Mobile Menu Toggle */}
        <button
          className="md:hidden text-white"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        >
          {mobileMenuOpen ? <X /> : <Menu />}
        </button>
      </div>

      {/* Mobile Menu */}
      {mobileMenuOpen && (
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="md:hidden absolute top-full left-0 right-0 bg-[#0F172A] border-b border-white/10 p-6 flex flex-col gap-4 shadow-xl"
        >
          <Link href="#features" className="text-slate-300 hover:text-white py-2" onClick={() => setMobileMenuOpen(false)}>المميزات</Link>
          <Link href="#showcase" className="text-slate-300 hover:text-white py-2" onClick={() => setMobileMenuOpen(false)}>المعرض</Link>
          <Link href="#install" className="w-full py-3 rounded-xl bg-white text-slate-900 font-bold text-center block" onClick={() => setMobileMenuOpen(false)}>
            حمل التطبيق
          </Link>
        </motion.div>
      )}
    </nav>
  );
};

const Hero = () => {
  return (
    <section className="relative min-h-screen flex items-center pt-32 pb-20 overflow-hidden bg-[#0F172A]">
      <div className="container mx-auto px-6 grid lg:grid-cols-2 gap-16 items-center relative z-10">
        <motion.div
          initial={{ opacity: 0, x: 50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
          className="text-right lg:order-1"
        >
          <h1 className="text-5xl md:text-7xl font-bold leading-tight mb-8 text-white">
            حول خيالك <br />
            إلى واقع ملموس
          </h1>

          <p className="text-xl text-slate-400 mb-10 max-w-lg leading-relaxed mr-auto md:ml-0 ml-auto">
            أنتج فيديوهات سينمائية وصوراً مذهلة في ثوانٍ. القوة الكاملة للذكاء الاصطناعي الآن في جيبك.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-start">
            <Link href="#install" className="flex items-center justify-center gap-3 px-8 py-4 bg-purple-600 text-white rounded-xl font-bold hover:bg-purple-700 transition-colors shadow-lg shadow-purple-900/20">
              <span className="text-lg">حمل التطبيق الآن</span>
              <Download size={20} />
            </Link>
            <Link href="#showcase" className="flex items-center justify-center gap-3 px-8 py-4 bg-white/5 text-white rounded-xl font-bold hover:bg-white/10 border border-white/10 transition-colors">
              <span className="text-lg">شاهد المعرض</span>
              <Play size={20} />
            </Link>
          </div>

          <div className="mt-10 flex items-center gap-4 text-sm text-slate-500 justify-start">
            <div className="flex items-center gap-2">
              <CheckCircle2 className="text-green-500" size={16} />
              <span>بدون اشتراك شهري معقد</span>
            </div>
            <div className="w-1 h-1 rounded-full bg-slate-600" />
            <div className="flex items-center gap-2">
              <CheckCircle2 className="text-green-500" size={16} />
              <span>يدعم اللغة العربية</span>
            </div>
          </div>
        </motion.div>

        <motion.div
          className="relative lg:h-[800px] flex items-center justify-center lg:order-2"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.2 }}
        >
          {/* Phone Mockup - Simple & Clean */}
          <div className="relative w-[300px] sm:w-[340px] h-[640px] sm:h-[700px] bg-slate-900 rounded-[48px] border-8 border-slate-800 shadow-2xl overflow-hidden hover:scale-105 transition-transform duration-500 ease-out">
            {/* Screen Content */}
            <div className="absolute inset-0 bg-slate-950">
              {/* UI Header */}
              <div className="absolute top-0 left-0 right-0 h-28 p-8 flex justify-between items-end bg-gradient-to-b from-slate-900 to-transparent z-10" dir="rtl">
                <Menu className="text-white" />
                <span className="text-white font-bold">أقفيو</span>
              </div>

              {/* Feed */}
              <div className="absolute inset-0 pt-28 px-4 pb-24 overflow-hidden space-y-4">
                {/* Generated Item 1 */}
                <div className="aspect-[4/5] bg-slate-800 rounded-3xl overflow-hidden relative">
                  <div className="absolute inset-0 flex items-center justify-center text-slate-600">
                    <ImageIcon size={48} />
                  </div>
                  {/* Overlay Label */}
                  <div className="absolute bottom-4 right-4 bg-black/60 px-3 py-1 rounded-full backdrop-blur-sm">
                    <span className="text-xs text-white font-medium">سايبربانك</span>
                  </div>
                </div>
                {/* Generated Item 2 */}
                <div className="aspect-[4/5] bg-slate-800 rounded-3xl" />
              </div>

              {/* Add Button */}
              <div className="absolute bottom-8 left-1/2 -translate-x-1/2 w-16 h-16 bg-purple-600 rounded-full flex items-center justify-center text-white shadow-lg shadow-purple-900/50 z-20">
                <Wand2 />
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

interface FeatureCardProps {
  icon: React.ElementType;
  title: string;
  description: string;
}

const FeatureCard = ({ icon: Icon, title, description }: FeatureCardProps) => {
  return (
    <div className="p-8 rounded-3xl bg-slate-800/50 border border-white/5 hover:border-purple-500/30 transition-colors text-right group">
      <div className="w-14 h-14 rounded-2xl bg-slate-800 flex items-center justify-center mb-6 text-purple-400 ms-auto group-hover:bg-purple-500 group-hover:text-white transition-all">
        <Icon size={28} />
      </div>

      <h3 className="text-xl font-bold mb-3 text-white">{title}</h3>
      <p className="text-slate-400 leading-relaxed text-sm">
        {description}
      </p>
    </div>
  );
};

const Features = () => {
  const features = [
    {
      icon: Video,
      title: "نصوص إلى فيديو",
      description: "حول الوصف النصي البسيط إلى فيديوهات عالية الجودة وانسيابية.",
    },
    {
      icon: ImageIcon,
      title: "صور إلى فيديو",
      description: "اجعل صورك الثابتة تنبض بالحياة مع تقنيات التحريك المتقدمة.",
    },
    {
      icon: Wand2,
      title: "المحسن الذكي",
      description: "ميزة 'تحسين الوصف' تقوم بتوسيع أفكارك البسيطة للحصول على أفضل النتائج.",
    },
    {
      icon: Zap,
      title: "سرعة فائقة",
      description: "استمتع بتجربة إبداعية فورية مع أسرع خوادم المعالجة.",
    }
  ];

  return (
    <section id="features" className="py-32 bg-[#0B1221]">
      <div className="container mx-auto px-6">
        <div className="text-center mb-20">
          <h2 className="text-3xl md:text-5xl font-bold mb-6 text-white">
            كل ما تحتاجه للإبداع
          </h2>
          <p className="text-slate-400 max-w-2xl mx-auto">
            أدوات احترافية صممت لتكون سهلة الاستخدام للجميع.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((f, i) => (
            <FeatureCard key={i} {...f} />
          ))}
        </div>
      </div>
    </section>
  );
};

const Showcase = () => {
  return (
    <section id="showcase" className="py-32 bg-[#0F172A]">
      <div className="container mx-auto px-6">
        <div className="flex flex-col md:flex-row items-center justify-between mb-16 gap-6">
          <div className="text-right w-full">
            <h2 className="text-3xl md:text-5xl font-bold text-white mb-4">معرض الأعمال</h2>
            <p className="text-slate-400">نماذج مما قام مستخدمونا بإنشائه</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {[1, 2, 3].map((i) => (
            <div key={i} className="group relative aspect-[9/16] rounded-3xl overflow-hidden bg-slate-800 border-4 border-slate-800 shadow-xl">
              {/* Placeholder for video content */}
              <div className="absolute inset-0 flex items-center justify-center bg-slate-900 text-slate-700">
                <Play size={48} opacity={0.5} />
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

const InstallSection = () => {
  return (
    <section id="install" className="py-32 bg-[#0B1221]">
      <div className="container mx-auto px-6 max-w-5xl">
        <div className="bg-purple-600 rounded-[3rem] p-12 md:p-20 text-center relative overflow-hidden">
          {/* Simple Pattern overlay */}
          <div className="absolute inset-0 opacity-10 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-white to-transparent" />

          <div className="relative z-10">
            <h2 className="text-3xl md:text-5xl font-bold mb-8 text-white">انطلق في رحلة الإبداع</h2>
            <p className="text-lg text-purple-100 mb-12 max-w-2xl mx-auto">
              حمل التطبيق اليوم وابدأ بصناعة محتوى لا ينسى. متاح مجاناً.
            </p>

            <div className="flex flex-col md:flex-row justify-center gap-6">
              <Link href="https://apps.apple.com" className="flex items-center gap-4 bg-white hover:bg-slate-100 text-slate-900 px-6 py-4 rounded-2xl transition-all hover:-translate-y-1 shadow-xl text-right items-end justify-center">
                <div className="text-black">
                  <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.23-3.14-2.47-1.7-2.45-3-7-1.18-10.16.9-1.55 2.54-2.51 4.31-2.54 1.29-.01 2.41.84 3.19.84.78 0 2.14-.84 3.59-.81 1.23.06 2.34.49 3.14 1.27-2.61 1.55-2.18 5.76.5 6.94-.48 1.44-1.12 2.87-1.8 3.87zm-4.32-15.6c.67-.84.97-1.92.83-2.9-1.52.06-3 .92-3.83 1.94-.78.96-1.13 2.15-.89 2.97 1.69.13 3.19-1.17 3.89-2.01z" /></svg>
                </div>
                <div>
                  <div className="text-xs">حمله الآن من</div>
                  <div className="text-xl font-bold">App Store</div>
                </div>
              </Link>

              <Link href="https://play.google.com" className="flex items-center gap-4 bg-slate-900 hover:bg-slate-800 text-white px-6 py-4 rounded-2xl transition-all hover:-translate-y-1 shadow-xl text-right items-end justify-center border border-white/10">
                <div>
                  <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor"><path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z" /></svg>
                </div>
                <div>
                  <div className="text-xs">احصل عليه من</div>
                  <div className="text-xl font-bold">Google Play</div>
                </div>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

const Footer = () => {
  return (
    <footer className="bg-[#050914] border-t border-white/5 pt-20 pb-10">
      <div className="container mx-auto px-6">
        <div className="grid md:grid-cols-4 gap-12 mb-16 px-4">
          <div className="col-span-1 md:col-span-2 text-right">
            <Link href="/" className="flex items-center gap-3 mb-6 justify-end md:justify-start">
              <div className="w-10 h-10 relative rounded-lg overflow-hidden border border-white/10">
                <Image src="/logo.jpeg" alt="Logo" fill className="object-cover" />
              </div>
              <span className="text-xl font-bold text-white">أقفيو</span>
            </Link>
            <p className="text-slate-400 max-w-sm mb-6 mr-auto md:ml-0 md:mr-0">
              الجناح الإبداعي المتكامل للذكاء الاصطناعي.
            </p>
          </div>

          <div className="text-right">
            <ul className="space-y-4 text-slate-400 text-sm">
              <li><Link href="#features" className="hover:text-purple-400 transition-colors">المميزات</Link></li>
              <li><Link href="#showcase" className="hover:text-purple-400 transition-colors">المعرض</Link></li>
              <li><Link href="#install" className="hover:text-purple-400 transition-colors">التحميل</Link></li>
            </ul>
          </div>

          <div className="text-right">
            <ul className="space-y-4 text-slate-400 text-sm">
              <li><Link href="/privacy" className="hover:text-purple-400 transition-colors">سياسة الخصوصية</Link></li>
              <li><Link href="/terms" className="hover:text-purple-400 transition-colors">الشروط والأحكام</Link></li>
              <li><Link href="/support" className="hover:text-purple-400 transition-colors">الدعم الفني</Link></li>
            </ul>
          </div>
        </div>

        <div className="border-t border-white/5 pt-8 flex flex-col md:flex-row-reverse items-center justify-between gap-4">
          <p className="text-slate-500 text-sm">© 2024 أقفيو للذكاء الاصطناعي.</p>
        </div>
      </div>
    </footer>
  );
};

export default function Home() {
  return (
    <main className="min-h-screen bg-[#0F172A] text-white selection:bg-purple-500/30 selection:text-white pb-0">
      <Navbar />
      <Hero />
      <Features />
      <Showcase />
      <InstallSection />
      <Footer />
    </main>
  );
}
