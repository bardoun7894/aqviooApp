import Link from "next/link";
import { ArrowLeft, Mail, Book, LifeBuoy } from "lucide-react";

export default function SupportPage() {
          return (
                    <main className="min-h-screen bg-[#0F172A] text-white py-20 px-6">
                              <div className="container mx-auto max-w-4xl">
                                        <Link href="/" className="inline-flex items-center gap-2 text-purple-400 mb-8 hover:text-purple-300 transition-colors">
                                                  <ArrowLeft size={20} />
                                                  العودة للرئيسية
                                        </Link>

                                        <h1 className="text-4xl font-bold mb-4 text-gradient">مركز الدعم</h1>
                                        <p className="text-xl text-slate-400 mb-12">كيف يمكننا مساعدتك اليوم؟</p>

                                        <div className="grid md:grid-cols-2 gap-6 mb-16">
                                                  {/* Contact Card */}
                                                  <div className="bg-white/5 p-8 rounded-3xl border border-white/10 hover:border-purple-500/50 transition-colors group">
                                                            <div className="w-14 h-14 rounded-2xl bg-purple-500/20 flex items-center justify-center text-purple-400 mb-6 group-hover:scale-110 transition-transform">
                                                                      <Mail size={32} />
                                                            </div>
                                                            <h2 className="text-2xl font-bold mb-3">تواصل معنا</h2>
                                                            <p className="text-slate-400 mb-6">
                                                                      لديك استفسار أو واجهت مشكلة؟ فريقنا جاهز للمساعدة في أي وقت.
                                                            </p>
                                                            <a href="mailto:support@aqvioo.com" className="text-white font-semibold flex items-center gap-2 hover:text-purple-400">
                                                                      support@aqvioo.com
                                                            </a>
                                                  </div>

                                                  {/* FAQ Card */}
                                                  <div className="bg-white/5 p-8 rounded-3xl border border-white/10 hover:border-pink-500/50 transition-colors group">
                                                            <div className="w-14 h-14 rounded-2xl bg-pink-500/20 flex items-center justify-center text-pink-400 mb-6 group-hover:scale-110 transition-transform">
                                                                      <Book size={32} />
                                                            </div>
                                                            <h2 className="text-2xl font-bold mb-3">الأسئلة الشائعة</h2>
                                                            <p className="text-slate-400 mb-6">
                                                                      تصفح قاعدة المعرفة للحصول على إجابات سريعة حول كيفية استخدام التطبيق.
                                                            </p>
                                                            <Link href="#" className="text-white font-semibold flex items-center gap-2 hover:text-pink-400">
                                                                      تصفح المقالات
                                                            </Link>
                                                  </div>
                                        </div>

                                        {/* Common Issues */}
                                        <section>
                                                  <h3 className="text-2xl font-bold mb-8">مشاكل شائعة وحلولها</h3>
                                                  <div className="space-y-4">
                                                            {[
                                                                      { q: "لماذا فشل إنشاء الفيديو؟", a: "قد يحدث هذا بسبب ضغط الخادم أو انقطاع الاتصال. يرجى المحاولة مرة أخرى بعد دقيقة." },
                                                                      { q: "كيف يمكنني استعادة المشتريات؟", a: "انتقل إلى الإعدادات > الاشتراكات واضغط على 'استعادة المشتريات'." },
                                                                      { q: "كيف أحذف حسابي؟", a: "يمكنك طلب حذف الحساب من خلال إعدادات التطبيق أو التواصل معنا عبر البريد الإلكتروني." }
                                                            ].map((item, i) => (
                                                                      <div key={i} className="bg-slate-900/50 p-6 rounded-2xl border border-white/5">
                                                                                <h4 className="font-bold text-white mb-2 flex items-center gap-2">
                                                                                          <LifeBuoy size={18} className="text-slate-500" />
                                                                                          {item.q}
                                                                                </h4>
                                                                                <p className="text-slate-400 text-sm mr-6">{item.a}</p>
                                                                      </div>
                                                            ))}
                                                  </div>
                                        </section>

                              </div>
                    </main>
          );
}
