import Link from "next/link";
import { ArrowLeft, FileText, AlertCircle } from "lucide-react";

export default function TermsPage() {
          return (
                    <main className="min-h-screen bg-[#0F172A] text-white py-20 px-6">
                              <div className="container mx-auto max-w-4xl">
                                        <Link href="/" className="inline-flex items-center gap-2 text-purple-400 mb-8 hover:text-purple-300 transition-colors">
                                                  <ArrowLeft size={20} />
                                                  العودة للرئيسية
                                        </Link>

                                        <h1 className="text-4xl font-bold mb-12 text-gradient">الشروط والأحكام</h1>

                                        <div className="space-y-12">
                                                  {/* Agreement */}
                                                  <section className="bg-white/5 p-8 rounded-3xl border border-white/10">
                                                            <div className="flex items-center gap-4 mb-6">
                                                                      <div className="w-12 h-12 rounded-xl bg-purple-500/20 flex items-center justify-center text-purple-400">
                                                                                <FileText size={24} />
                                                                      </div>
                                                                      <h2 className="text-2xl font-bold">اتفاقية الاستخدام</h2>
                                                            </div>
                                                            <p className="text-slate-300 leading-relaxed">
                                                                      تحكم شروط الخدمة هذه استخدامك لتطبيق أقفيو. من خلال استخدام التطبيق، فإنك توافق على الالتزام بهذه الشروط. إذا كنت لا توافق على هذه الشروط، فلا يحق لك استخدام التطبيق.
                                                            </p>
                                                  </section>

                                                  {/* Licensing */}
                                                  <section>
                                                            <h3 className="text-2xl font-bold mb-6 text-white border-r-4 border-purple-500 pr-4">حقوق الملكية الفكرية</h3>
                                                            <div className="space-y-6 text-slate-300">
                                                                      <p>
                                                                                التطبيق ومحتواه الأصلي وميزاته ووظائفه هي ملك لشركة أقفيو ومحمية بموجب قوانين حقوق النشر الدولية والعلامات التجارية وبراءات الاختراع والأسرار التجارية وقوانين الملكية الفكرية الأخرى.
                                                                      </p>
                                                                      <div className="p-6 rounded-2xl bg-slate-900 border border-white/5">
                                                                                <h4 className="font-bold text-white mb-2">المحتوى الخاص بك</h4>
                                                                                <p>أنت تحتفظ بملكية المحتوى الذي تقوم بإنشائه باستخدام التطبيق. ومع ذلك، بمنحك لنا ترخيصاً لاستخدام وعرض وتشغيل ونسخ هذا المحتوى لغرض تقديم الخدمة.</p>
                                                                      </div>
                                                            </div>
                                                  </section>

                                                  {/* Restrictions */}
                                                  <section>
                                                            <h3 className="text-2xl font-bold mb-6 text-white border-r-4 border-pink-500 pr-4">الاستخدام المحظور</h3>
                                                            <p className="text-slate-300 mb-4">توافق على عدم استخدام التطبيق من أجل:</p>
                                                            <ul className="list-disc list-inside space-y-3 text-slate-300 mr-2">
                                                                      <li>إنشاء محتوى غير قانوني، ضار، مهدد، مسيء، أو تشهيري.</li>
                                                                      <li>انتحال شخصية أي شخص أو كيان.</li>
                                                                      <li>انتهاك حقوق الملكية الفكرية للآخرين.</li>
                                                                      <li>نشر الفيروسات أو البرامج الضارة.</li>
                                                            </ul>
                                                  </section>

                                                  {/* Disclaimer */}
                                                  <section className="bg-slate-800/50 p-6 rounded-2xl border border-white/5">
                                                            <h3 className="font-bold text-white mb-4 flex items-center gap-2">
                                                                      <AlertCircle size={20} className="text-orange-400" />
                                                                      إخلاء المسؤولية
                                                            </h3>
                                                            <p className="text-slate-400 text-sm">
                                                                      يتم توفير التطبيق &quot;كما هو&quot; و&quot;كما هو متاح&quot; دون أي ضمانات من أي نوع. لا نضمن أن التطبيق سيعمل دون انقطاع أو أنه خالٍ من الأخطاء. استخدام مخرجات الذكاء الاصطناعي يكون على مسؤوليتك الخاصة.
                                                            </p>
                                                  </section>

                                                  <div className="pt-8 border-t border-white/10 text-center">
                                                            <p className="text-slate-500 text-sm">للتواصل القانوني: legal@aqvioo.com</p>
                                                  </div>
                                        </div>
                              </div>
                    </main>
          );
}
