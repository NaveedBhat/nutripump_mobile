import '../../services/legal_service.dart';

final LegalPage defaultPrivacyPage = LegalPage(
    title: "Privacy Policy",
    intro:
        "This Privacy Policy applies to all products and services offered by NutriPump Artisanal (\"NutriPump\", \"we\", \"our\", or \"us\"), including our website at nutripump.com and our mobile applications. By using our services, you agree to the collection and use of information in accordance with this policy.",
    sections: [
      LegalSection(icon: "eye", title: "Information We Collect", items: [
        LegalItem(
            subtitle: "Information You Provide",
            text:
                "When you create an account, place an order, or contact us, we collect information such as your name, email address, shipping and billing address, phone number, and payment details. Payment card details are processed securely by our payment partners and are never stored on our servers."),
        LegalItem(
            subtitle: "Information Collected Automatically",
            text:
                "When you visit our website or mobile application, we automatically collect certain information, including your IP address, browser type, operating system, referring URLs, pages viewed, and the dates and times of your visits. We use cookies and similar tracking technologies to personalise and enhance your experience."),
        LegalItem(
            subtitle: "Information from Third Parties",
            text:
                "We may receive information about you from third-party partners, such as social media platforms (if you choose to connect your account) or analytics providers, to help us better understand how our services are used and to improve them for all customers.")
      ]),
      LegalSection(
          icon: "update",
          title: "How We Use Your Information",
          items: [
            LegalItem(
                subtitle: "Order Fulfillment & Customer Service",
                text:
                    "We use your information primarily to process and fulfil your orders, send order confirmations and shipping notifications, respond to your inquiries and support requests, and manage your account and purchase history."),
            LegalItem(
                subtitle: "Personalisation & Improvement",
                text:
                    "We analyse usage patterns to improve our website, mobile app, and product offerings. We may use your purchase history and browsing behaviour to personalise your experience and recommend products we think you'll love."),
            LegalItem(
                subtitle: "Marketing Communications",
                text:
                    "With your consent, we may send you newsletters, promotional offers, and updates about new products or artisan harvests from Kashmir. You may opt out of marketing emails at any time by clicking the \"Unsubscribe\" link in any marketing email or by updating your account preferences."),
            LegalItem(
                subtitle: "Legal & Security",
                text:
                    "We may use your information to comply with applicable laws and regulations, detect and prevent fraudulent transactions, enforce our Terms of Service, and protect the rights, property, or safety of NutriPump Artisanal, our customers, or others.")
          ]),
      LegalSection(
          icon: "share",
          title: "How We Share Your Information",
          items: [
            LegalItem(
                subtitle: "Service Providers",
                text:
                    "We share your information with trusted third-party service providers who assist us in operating our business, including payment processors, shipping and logistics partners, cloud infrastructure providers (Firebase, Google Cloud), and email communication services. These providers are contractually required to keep your information confidential and to use it only as directed by us."),
            LegalItem(
                subtitle: "Business Transfers",
                text:
                    "If NutriPump Artisanal is involved in a merger, acquisition, or sale of all or a portion of its assets, your information may be transferred as part of that transaction. We will notify you of any such change in ownership or control of your personal information."),
            LegalItem(
                subtitle: "Legal Requirements",
                text:
                    "We may disclose your information if required to do so by law or in the good faith belief that such action is necessary to comply with a legal obligation, protect and defend our rights or property, act in urgent circumstances to protect the personal safety of users of our services or the public, or protect against legal liability.")
          ]),
      LegalSection(icon: "lock", title: "Data Security & Retention", items: [
        LegalItem(
            subtitle: "Security Measures",
            text:
                "We implement industry-standard administrative, technical, and physical security measures to protect your personal information from unauthorised access, use, alteration, or disclosure. These include encryption of sensitive data (like passwords), secure HTTPS connections, and strict access controls for our staff."),
        LegalItem(
            subtitle: "No Absolute Guarantee",
            text:
                "While we strive to use commercially acceptable means to protect your personal information, no method of transmission over the internet or method of electronic storage is 100% secure. Therefore, we cannot guarantee its absolute security."),
        LegalItem(
            subtitle: "Data Retention",
            text:
                "We will retain your personal information only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use your information to the extent necessary to comply with our legal obligations, resolve disputes, and enforce our policies.")
      ]),
      LegalSection(
          icon: "tune",
          title: "Your Privacy Rights & Choices",
          items: [
            LegalItem(
                subtitle: "Access and Update",
                text:
                    "You can review and update your account information at any time by logging into your account settings via our website or mobile app."),
            LegalItem(
                subtitle: "Data Portability & Deletion",
                text:
                    "You have the right to request a copy of the personal data we hold about you or request that we delete your personal data. Please contact us to exercise these rights. Note that we may need to retain certain information for record-keeping purposes, to complete transactions, or to comply with our legal obligations."),
            LegalItem(
                subtitle: "Marketing Opt-Out",
                text:
                    "You can opt out of receiving promotional communications from us by following the instructions in those communications or by updating your account preferences. If you opt out, we may still send you non-promotional communications, such as those about your account or ongoing business relations.")
          ]),
      LegalSection(icon: "cookie", title: "Cookies & Tracking", items: [
        LegalItem(
            subtitle: "What are Cookies?",
            text:
                "Cookies are small data files placed on your device when you visit a website. We use cookies and similar tracking technologies to track activity on our services and hold certain information."),
        LegalItem(
            subtitle: "Types of Cookies We Use",
            text:
                "We use essential cookies for the operation of our platform (like keeping you logged in), preference cookies to remember your settings, and analytics cookies to understand how visitors interact with our services."),
        LegalItem(
            subtitle: "Managing Cookies",
            text:
                "You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent. However, if you do not accept cookies, you may not be able to use some portions of our services.")
      ]),
      LegalSection(icon: "child", title: "Children's Privacy", items: [
        LegalItem(
            subtitle: "Age Restriction",
            text:
                "Our services are not intended for use by anyone under the age of 18. We do not knowingly collect personally identifiable information from anyone under the age of 18."),
        LegalItem(
            subtitle: "Parental Rights",
            text:
                "If you are a parent or guardian and you are aware that your child has provided us with personal data, please contact us. If we become aware that we have collected personal data from anyone under the age of 18 without verification of parental consent, we take steps to remove that information from our servers.")
      ]),
      LegalSection(icon: "update", title: "Policy Updates", items: [
        LegalItem(
            subtitle: "Changes to this Policy",
            text:
                "We may update this Privacy Policy from time to time to reflect changes in our practices or for other operational, legal, or regulatory reasons. We will notify you of any material changes by posting the new policy on this page and updating the \"Last Updated\" date. For significant changes, we may also send a notification to your registered email address.")
      ])
    ]);

final LegalPage defaultTermsPage = LegalPage(
    title: "Terms of Service",
    intro:
        "These Terms of Service (\"Terms\") constitute a legally binding agreement between you and NutriPump Artisanal (\"NutriPump\", \"we\", \"our\", or \"us\"), governing your access to and use of our website at nutripump.com, our mobile applications, and the purchase of our products. If you have any questions about these Terms, please contact us before using our services.",
    sections: [
      LegalSection(icon: "handshake", title: "Acceptance of Terms", items: [
        LegalItem(
            subtitle: "Agreement to Terms",
            text:
                "By accessing or using the NutriPump Artisanal website (nutripump.com), mobile applications, or any of our services, you confirm that you are at least 18 years of age, have read and understood these Terms of Service, and agree to be bound by them. If you do not agree to these terms, please do not use our services."),
        LegalItem(
            subtitle: "Updates to Terms",
            text:
                "NutriPump Artisanal reserves the right to modify these Terms at any time. Changes take effect immediately upon posting to our website or app. Your continued use of our services after any modification constitutes your acceptance of the revised Terms.")
      ]),
      LegalSection(icon: "person", title: "User Accounts", items: [
        LegalItem(
            subtitle: "Account Registration",
            text:
                "To place orders or access certain features, you may be required to create an account. You agree to provide accurate, complete, and current information during registration and to keep your account credentials confidential. You are solely responsible for all activity that occurs under your account. We also offer a guest checkout option for orders without account registration."),
        LegalItem(
            subtitle: "Account Security",
            text:
                "You must immediately notify us if you suspect any unauthorised use of your account. NutriPump Artisanal will not be liable for any losses arising from unauthorised use of your account if you have failed to safeguard your credentials."),
        LegalItem(
            subtitle: "Account Termination",
            text:
                "We reserve the right to suspend or terminate your account at our sole discretion, without notice, for conduct that we believe violates these Terms, is harmful to other users, third parties, or the interests of NutriPump Artisanal, or for any other reason we deem appropriate.")
      ]),
      LegalSection(icon: "cart", title: "Orders & Payments", items: [
        LegalItem(
            subtitle: "Order Acceptance",
            text:
                "Placing an order constitutes an offer to purchase our products. We reserve the right to accept or decline your order at our sole discretion. An order is confirmed when you receive an order confirmation notification. We may cancel orders due to product unavailability, errors in pricing or product description, or suspected fraudulent activity."),
        LegalItem(
            subtitle: "Pricing & Availability",
            text:
                "All prices are displayed in Indian Rupees (INR). We reserve the right to change prices at any time without prior notice. Products are subject to availability and we cannot guarantee that items will be in stock at the time of your order."),
        LegalItem(
            subtitle: "Payment",
            text:
                "We accept online payments (credit card, debit card, UPI, and net banking) processed securely via Razorpay, as well as Cash on Delivery (COD) where available. The payment methods available to you are displayed at checkout. By providing payment information, you represent that you are authorised to use that payment method and authorise us to charge the total amount due."),
        LegalItem(
            subtitle: "GST & Taxes",
            text:
                "Applicable Goods and Services Tax (GST) will be added to your order total as required by Indian law. The applicable rate may vary depending on the product category. GST amounts are displayed in your order summary and on your invoice."),
        LegalItem(
            subtitle: "Order Cancellation by Customer",
            text:
                "You may cancel your order within the cancellation window (as displayed in the app or website) of placing it, provided it has not yet been dispatched. After this window, orders cannot be self-cancelled and you must contact our support team to request a manual review.")
      ]),
      LegalSection(icon: "truck", title: "Shipping & Delivery", items: [
        LegalItem(
            subtitle: "Delivery Timelines",
            text:
                "We aim to dispatch all orders within 1–3 business days of payment confirmation. Estimated delivery times are 4–7 business days for standard shipping within India and may vary by location, season, and logistics partner capacity. Delivery timelines are estimates only and are not guarantees."),
        LegalItem(
            subtitle: "Shipping Charges",
            text:
                "Shipping charges are calculated based on your delivery location and displayed at checkout. Orders above a configured threshold qualify for free shipping. Below this threshold, a flat shipping fee applies. These thresholds are subject to change at any time."),
        LegalItem(
            subtitle: "Risk of Loss",
            text:
                "Title and risk of loss for all products pass to you upon our delivery to the carrier. NutriPump Artisanal is not responsible for delays or damages caused by the carrier after dispatch. We will, however, work with you to resolve any issues with lost or damaged shipments in good faith."),
        LegalItem(
            subtitle: "Failed Deliveries",
            text:
                "If a delivery attempt fails due to an incorrect address provided by the customer or unavailability of the recipient, the package may be returned to us. Re-shipping charges will apply. NutriPump Artisanal is not responsible for lost orders due to incorrect address information provided at checkout.")
      ]),
      LegalSection(icon: "undo", title: "Returns & Refunds", items: [
        LegalItem(
            subtitle: "Eligibility for Returns",
            text:
                "We accept return or replacement requests for products that arrive damaged, defective, or significantly different from their description. You must initiate a return request within the return window (as displayed in the app and on the order detail screen) of receiving your order. Due to the perishable and artisanal nature of our products, we do not accept returns for reasons of personal taste or preference."),
        LegalItem(
            subtitle: "How to Request a Return",
            text:
                "To initiate a return or replacement, use the \"Returns & Refunds\" option in your account, contact our support team, or visit our Support page within the return window. Please include your order ID, a description of the issue, and clear photographs of the product and packaging."),
        LegalItem(
            subtitle: "Refund Process",
            text:
                "Approved refunds will be processed to your original payment method within 7–10 business days. Shipping charges are non-refundable unless the return is due to our error or a product defect."),
        LegalItem(
            subtitle: "Non-Returnable Items",
            text:
                "Opened perishable goods, items on sale or clearance, and products that have been used or consumed cannot be returned. Gift cards and digital vouchers are non-refundable.")
      ]),
      LegalSection(icon: "copyright", title: "Intellectual Property", items: [
        LegalItem(
            subtitle: "Our Content",
            text:
                "All content on NutriPump Artisanal's website and mobile applications — including text, graphics, logos, images, product photographs, audio, and software — is the exclusive property of NutriPump Artisanal or its content suppliers and is protected by applicable intellectual property laws."),
        LegalItem(
            subtitle: "Limited License",
            text:
                "We grant you a limited, non-exclusive, non-transferable, revocable licence to access and use our app for personal, non-commercial purposes only. You may not reproduce, distribute, modify, create derivative works of, or commercially exploit any content without our express written permission."),
        LegalItem(
            subtitle: "User-Generated Content",
            text:
                "By submitting reviews, photographs, or other content to our platform, you grant NutriPump Artisanal a non-exclusive, royalty-free, perpetual, and irrevocable right to use, reproduce, modify, and display such content in connection with our services and marketing activities.")
      ]),
      LegalSection(icon: "warning", title: "Disclaimers & Limitations", items: [
        LegalItem(
            subtitle: "Health Disclaimers",
            text:
                "Our products are natural artisanal food products and are not intended to diagnose, treat, cure, or prevent any disease or health condition. Any health-related information on our platform is provided for informational purposes only and should not be construed as medical advice. Always consult a qualified healthcare professional before making significant dietary changes."),
        LegalItem(
            subtitle: "Warranty Disclaimer",
            text:
                "Our services and products are provided on an \"as is\" and \"as available\" basis without warranties of any kind, either express or implied. We do not warrant that the app will be uninterrupted or error-free."),
        LegalItem(
            subtitle: "Limitation of Liability",
            text:
                "To the maximum extent permitted by applicable law, NutriPump Artisanal shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of our services or products. Our total liability to you shall not exceed the amount you paid for the specific product or service giving rise to the claim.")
      ]),
      LegalSection(icon: "block", title: "Prohibited Conduct", items: [
        LegalItem(
            subtitle: "You Agree Not To",
            text:
                "Use our services for any unlawful purpose or in violation of any regulations; transmit any unsolicited or unauthorised advertising material; attempt to gain unauthorised access to our systems or networks; engage in any conduct that restricts or inhibits any other user from using our services; use automated means to scrape, crawl, or extract data from our app or website; or impersonate any person or entity."),
        LegalItem(
            subtitle: "Consequences of Violation",
            text:
                "Violations of this section may result in immediate termination of your account, civil or criminal legal action, and/or reporting to appropriate law enforcement authorities. We reserve the right to investigate and prosecute violations to the fullest extent permitted by law.")
      ]),
      LegalSection(icon: "balance", title: "Governing Law & Disputes", items: [
        LegalItem(
            subtitle: "Governing Law",
            text:
                "These Terms shall be governed by and construed in accordance with the laws of the Republic of India, without regard to its conflict of law provisions. Any disputes arising out of or relating to these Terms or our services shall be subject to the exclusive jurisdiction of the courts located in Srinagar, Jammu & Kashmir, India."),
        LegalItem(
            subtitle: "Dispute Resolution",
            text:
                "We encourage you to contact us first to resolve any disputes amicably. For any unresolved disputes, the parties agree to attempt in good faith to resolve the matter through mediation before initiating formal legal proceedings."),
        LegalItem(
            subtitle: "Severability",
            text:
                "If any provision of these Terms is held to be invalid or unenforceable, that provision shall be limited or eliminated to the minimum extent necessary, and the remaining provisions shall continue in full force and effect.")
      ]),
      LegalSection(icon: "link", title: "Third-Party Links & Services", items: [
        LegalItem(
            subtitle: "External Links",
            text:
                "Our app may contain links to third-party websites or services. These links are provided for your convenience only. NutriPump Artisanal has no control over the content of those sites and accepts no responsibility for them."),
        LegalItem(
            subtitle: "Third-Party Services",
            text:
                "We use third-party services to operate our platform, including payment processors (Razorpay), analytics providers (Firebase Analytics), and cloud hosting. Your use of these services may be subject to their own terms and privacy policies.")
      ])
    ]);
