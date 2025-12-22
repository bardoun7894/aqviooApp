import Link from "next/link";
import { ArrowLeft, Shield, Eye } from "lucide-react";

export default function PrivacyPage() {
          return (
                    <main className="min-h-screen bg-[#0F172A] text-white py-20 px-6">
                              <div className="container mx-auto max-w-4xl">
                                        <Link href="/" className="inline-flex items-center gap-2 text-purple-400 mb-8 hover:text-purple-300 transition-colors">
                                                  <ArrowLeft size={20} />
                                                  العودة للرئيسية
                                        </Link>

                                        <h1 className="text-4xl font-bold mb-12 text-gradient">سياسة الخصوصية</h1>

                                        <div className="space-y-12">
                                                  {/* Introduction */}
                                                  <section className="bg-white/5 p-8 rounded-3xl border border-white/10">
                                                            <div className="flex items-center gap-4 mb-6">
                                                                      <div className="w-12 h-12 rounded-xl bg-purple-500/20 flex items-center justify-center text-purple-400">
                                                                                <Shield size={24} />
                                                                      </div>
                                                                      <h2 className="text-2xl font-bold">مقدمة</h2>
                                                            </div>
                                                            <p className="text-slate-300 leading-relaxed">
                                                                      تلتزم أقفيو (&quot;نحن&quot;، &quot;لنا&quot;، أو &quot;خاصتنا&quot;) بحماية خصوصيتك. توضح سياسة الخصوصية هذه كيف نقوم بجمع واستخدام والكشف عن وحماية معلوماتك عند استخدامك لتطبيقنا &quot;أقفيو&quot; (المشار إليه بـ &quot;التطبيق&quot;). يرجى قراءة سياسة الخصوصية هذه بعناية. إذا كنت لا توافق على شروط سياسة الخصوصية هذه، يرجى عدم الوصول إلى التطبيق.
                                                            </p>
                                                  </section>

                                                  {/* Collection */}
                                                  <section>
                                                            <h3 className="text-2xl font-bold mb-6 text-white border-r-4 border-purple-500 pr-4">المعلومات التي نجمعها</h3>
                                                            <div className="space-y-6 text-slate-300">
                                                                      <div className="p-6 rounded-2xl bg-slate-900 border border-white/5">
                                                                                <h4 className="font-bold text-white mb-2">البيانات الشخصية</h4>
                                                                                <p>قد نجمع معلومات تعريف شخصية، مثل اسمك، عنوان بريدك الإلكتروني، ورقم هاتفك فقط عند التسجيل طوعاً في التطبيق.</p>
                                                                      </div>
                                                                      <div className="p-6 rounded-2xl bg-slate-900 border border-white/5">
                                                                                <h4 className="font-bold text-white mb-2">المحتوى المنشأ</h4>
                                                                                <p>نقوم بتخزين ومعالجة النصوص والصور التي تقوم برفعها، وكذلك الفيديوهات التي يتم إنشاؤها لغرض تقديم الخدمة وتحسين نماذج الذكاء الاصطناعي.</p>
                                                                      </div>
                                                                      <div className="p-6 rounded-2xl bg-slate-900 border border-white/5">
                                                                                <h4 className="font-bold text-white mb-2">بيانات الاستخدام</h4>
                                                                                <p>نقوم تلقائياً بجمع معلومات حول جهازك وتفاعلك مع التطبيق لتحسين تجربة المستخدم والأداء.</p>
                                                                      </div>
                                                            </div>
                                                  </section>

                                                  {/* Usage */}
                                                  <section>
                                                            <h3 className="text-2xl font-bold mb-6 text-white border-r-4 border-pink-500 pr-4">كيف نستخدم معلوماتك</h3>
                                                            <ul className="list-disc list-inside space-y-3 text-slate-300 mr-2">
                                                                      <li>لتقديم وتشغيل وصيانة تطبيقنا.</li>
                                                                      <li>لتحسين وتخصيص وتوسيع خدماتنا.</li>
                                                                      <li>لفهم وتحليل كيفية استخدامك لتطبيقنا.</li>
                                                                      <li>لتطوير منتجات وخدمات وميزات ووظائف جديدة.</li>
                                                                      <li>للتواصل معك، إما مباشرة أو من خلال أحد شركائنا، لخدمة العملاء.</li>
                                                            </ul>
                                                  </section>

                                                  {/* AI Disclosure */}
                                                  <section className="bg-slate-800/50 p-6 rounded-2xl border border-white/5">
                                                            <h3 className="font-bold text-white mb-4 flex items-center gap-2">
                                                                      <Eye size={20} className="text-cyan-400" />
                                                                      إفصاح الذكاء الاصطناعي
                                                            </h3>
                                                            <p className="text-slate-400 text-sm">
                                                                      يستخدم هذا التطبيق تقنيات ذكاء اصطناعي من طرف ثالث (مثل OpenAI و Kling) لمعالجة مدخلاتك. لا نقوم بمشاركة معلوماتك الشخصية مع هذه الأطراف لأغراض التدريب دون موافقتك الصريحة، ولكن يتم إرسال المحتوى (النصوص/الصور) للمعالجة فقط.
                                                            </p>
                                                  </section>

                                                  <div className="pt-8 border-t border-white/10 text-center">
                                                            <p className="text-slate-500 text-sm">آخر تحديث: 23 ديسمبر 2024</p>
                                                  </div>
                                        </div>
                              </div>
                    </main>
          );
}
