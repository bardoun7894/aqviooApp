import type { Metadata } from "next";
import { Cairo } from "next/font/google";
import "./globals.css";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  variable: "--font-cairo",
  display: "swap",
});

export const metadata: Metadata = {
  title: "أقفيو - حول خيالك إلى واقع",
  description: "أنشئ فيديوهات وصور مذهلة في ثوانٍ باستخدام نماذج الذكاء الاصطناعي المتقدمة. حمل تطبيق أقفيو الآن.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body className={`${cairo.variable} font-sans antialiased bg-slate-900 text-white min-h-screen selection:bg-purple-500 selection:text-white`}>
        {children}
      </body>
    </html>
  );
}
