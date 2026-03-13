import type { Metadata } from "next";
import { Outfit, Cairo } from "next/font/google";
import "./globals.css";

const outfit = Outfit({
  subsets: ["latin"],
  variable: "--font-outfit",
  display: "swap",
  weight: ["300", "400", "500", "600", "700", "800", "900"],
});

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  variable: "--font-cairo",
  display: "swap",
  weight: ["300", "400", "500", "600", "700", "800", "900"],
});

export const metadata: Metadata = {
  title: "أقفيو — حوّل خيالك إلى واقع بصري مذهل",
  description:
    "أنشئ فيديوهات وصور احترافية بالذكاء الاصطناعي في ثوانٍ. نماذج Sora 2 و Veo 3.1 — نص إلى فيديو، صورة إلى فيديو، تعليق صوتي، و+15 أسلوب إبداعي. حمّل أقفيو الآن.",
  keywords: [
    "أقفيو",
    "Aqvioo",
    "ذكاء اصطناعي",
    "فيديو",
    "صور",
    "AI video",
    "text to video",
    "image to video",
  ],
  openGraph: {
    title: "أقفيو — حوّل خيالك إلى واقع بصري مذهل",
    description:
      "أنشئ فيديوهات وصور احترافية بالذكاء الاصطناعي في ثوانٍ.",
    type: "website",
    locale: "ar_SA",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                try {
                  var theme = localStorage.getItem('aqvioo-theme');
                  if (theme === 'light') {
                    document.documentElement.setAttribute('data-theme', 'light');
                  }
                } catch(e) {}
              })();
            `,
          }}
        />
      </head>
      <body
        className={`${outfit.variable} ${cairo.variable} font-body antialiased min-h-screen noise-overlay`}
      >
        {children}
      </body>
    </html>
  );
}
