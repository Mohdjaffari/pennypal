import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A structured section within an article (heading + body paragraph).
class ArticleSection {
  final String heading;
  final String body;

  const ArticleSection({required this.heading, required this.body});
}

/// Data model representing an educational article in the PennyPal Learning module.
/// Contains rich content: summary, key takeaways, structured sections, and practical steps.
class LearningArticleModel {
  final String id;
  final String title;
  final String duration;
  final String level;
  final String category; // 'Basics', 'Budgeting', 'Saving', 'Investing', 'Credit', 'Taxes'
  final Color imageColor;
  final Color backgroundColor;
  final IconData imageIcon;
  final String summary;

  /// Short bullet-point takeaways (3–5 items) shown at the top of the detail page.
  final List<String> keyTakeaways;

  /// Rich multi-section body content for the detail page.
  final List<ArticleSection> sections;

  /// Practical numbered action steps the reader can apply immediately.
  final List<String> actionSteps;

  /// Optional image asset path for rich visual cards and hero detail banners.
  final String? imagePath;

  /// Estimated reading progress label shown in card (e.g. 'Not started', 'In progress').
  final bool isCompleted;

  const LearningArticleModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.level,
    required this.category,
    required this.imageColor,
    required this.backgroundColor,
    required this.imageIcon,
    this.imagePath,
    this.summary = '',
    this.keyTakeaways = const [],
    this.sections = const [],
    this.actionSteps = const [],
    this.isCompleted = false,
  });

  /// Returns a copy of this model with [isCompleted] toggled.
  LearningArticleModel copyWith({bool? isCompleted, String? imagePath}) {
    return LearningArticleModel(
      id: id,
      title: title,
      duration: duration,
      level: level,
      category: category,
      imageColor: imageColor,
      backgroundColor: backgroundColor,
      imageIcon: imageIcon,
      imagePath: imagePath ?? this.imagePath,
      summary: summary,
      keyTakeaways: keyTakeaways,
      sections: sections,
      actionSteps: actionSteps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Canonical article library covering all major personal-finance categories.
  static List<LearningArticleModel> get defaultArticles => const [
        // ── Budgeting ──────────────────────────────────────────────────────────────
        LearningArticleModel(
          id: 'art_1',
          title: 'Smart Budgeting for Students',
          duration: '5 min',
          level: 'Beginner',
          category: 'Budgeting',
          imageColor: AppColors.shoppingOrange,
          backgroundColor: AppColors.shoppingOrangeLight,
          imageIcon: Icons.school_rounded,
          imagePath: 'assets/images/budgeting_hero.jpg',
          summary:
              'Learn the 50/30/20 rule tailored for student budgets and part-time income streams.',
          keyTakeaways: [
            'The 50/30/20 rule splits income into Needs, Wants, and Savings.',
            'Track every expense — even small daily coffees add up fast.',
            'Fixed costs (rent, tuition) should never exceed 50% of income.',
            'Automate your savings on payday so you never forget.',
            'Review your budget weekly and adjust before month-end.',
          ],
          sections: [
            ArticleSection(
              heading: 'What Is the 50/30/20 Rule?',
              body:
                  'The 50/30/20 rule is one of the most popular personal-finance frameworks because of its simplicity. You allocate 50% of your after-tax income to "Needs" — rent, utilities, groceries, and transport. Another 30% goes to "Wants" — dining out, streaming subscriptions, hobbies. The remaining 20% is directed straight into savings or debt repayment. For students with variable part-time income, it helps to calculate the rule on your average monthly earnings over the past three months.',
            ),
            ArticleSection(
              heading: 'Why Students Overspend',
              body:
                  'Common culprits include impulse food delivery orders, unused gym memberships, and social pressure to spend on entertainment. Small daily purchases — a Rs. 350 coffee every weekday equals over Rs. 9,000 per month — erode your budget silently. Awareness is the first step: categorize every transaction for one full month before drawing any conclusions.',
            ),
            ArticleSection(
              heading: 'Building Your Student Budget',
              body:
                  'Start by listing every fixed expense: rent, transport pass, phone bill, tuition instalment. These are your baseline. Next, look at the last 30 days of bank statements and categorize all variable spending. Finally, set a realistic cap for discretionary categories. Use PennyPal\'s Budget feature to receive alerts before you breach each cap.',
            ),
            ArticleSection(
              heading: 'Handling Irregular Income',
              body:
                  'Part-time salaries, freelance gigs, and family allowances can fluctuate. Build your budget around your lowest expected monthly income — treat any extra as a windfall and put 80% of it directly into savings. This conservative approach prevents over-committing on Wants during a good month.',
            ),
          ],
          actionSteps: [
            'Open your bank app and download last month\'s statement.',
            'Categorize each transaction as Need, Want, or Saving.',
            'Calculate your personal 50/30/20 split based on actual income.',
            'Set three budget limits in PennyPal — one per category.',
            'Schedule a 10-minute weekly money check-in every Sunday.',
          ],
        ),

        LearningArticleModel(
          id: 'art_2',
          title: 'Zero-Based Budgeting Explained',
          duration: '6 min',
          level: 'Intermediate',
          category: 'Budgeting',
          imageColor: AppColors.primaryBlue,
          backgroundColor: AppColors.primaryBlueLight,
          imageIcon: Icons.balance_rounded,
          imagePath: 'assets/images/budgeting_hero.jpg',
          summary:
              'Give every rupee a job. Zero-based budgeting forces intentional spending and eliminates financial blind spots.',
          keyTakeaways: [
            'Income minus all allocations should equal zero — nothing is "unaccounted for".',
            'ZBB requires you to justify every expense each month, not just new ones.',
            'It is especially powerful for breaking lifestyle creep.',
            'Pair it with envelope-style cash accounts for discretionary categories.',
            'Expect to spend 30–60 minutes setting it up each month.',
          ],
          sections: [
            ArticleSection(
              heading: 'The Core Idea',
              body:
                  'Zero-based budgeting (ZBB) means your income minus every planned outflow equals exactly zero. This does not mean you spend everything — savings, investments, and emergency fund contributions are just as valid "jobs" for your money as groceries. The key distinction from the 50/30/20 rule is intentionality: in ZBB, no rupee exists without a purpose.',
            ),
            ArticleSection(
              heading: 'Building a ZBB from Scratch',
              body:
                  'Begin with your total after-tax monthly income at the top. Then list every category in which you spend: housing, food, transport, personal care, entertainment, subscriptions, savings, investments, and emergency fund. Assign a rupee amount to each. Keep subtracting from income until you reach zero. If you run negative, cut discretionary items. If you have a surplus, redirect it to savings or debt.',
            ),
            ArticleSection(
              heading: 'Common Pitfalls',
              body:
                  'The biggest mistake is forgetting irregular expenses — car servicing, annual subscriptions, birthday gifts. Counter this by creating a "sinking fund" category in your budget where you set aside a small fixed amount each month for irregular but predictable costs. By the time the bill arrives, you already have the cash.',
            ),
          ],
          actionSteps: [
            'Write down your exact take-home income for this month.',
            'List every spending category you used in the past 60 days.',
            'Assign a ceiling amount to each category.',
            'Create a "Sinking Fund" line item for irregular costs.',
            'Reconcile your budget vs. actual spending at month-end.',
          ],
        ),

        // ── Saving ────────────────────────────────────────────────────────────────
        LearningArticleModel(
          id: 'art_3',
          title: 'Saving Tips That Actually Work',
          duration: '4 min',
          level: 'Beginner',
          category: 'Saving',
          imageColor: AppColors.primaryPink,
          backgroundColor: AppColors.primaryPinkLight,
          imageIcon: Icons.savings_rounded,
          imagePath: 'assets/images/saving_hero.jpg',
          summary:
              'Simple daily habits to automate micro-savings and build an emergency cushion you can rely on.',
          keyTakeaways: [
            'Pay yourself first — automate a savings transfer on payday.',
            'An emergency fund of 3–6 months of expenses is your financial shield.',
            'Micro-saving apps round up purchases to the nearest rupee automatically.',
            'Separate savings accounts reduce the temptation to spend.',
            'Even Rs. 50/day compounds into Rs. 18,250 per year.',
          ],
          sections: [
            ArticleSection(
              heading: 'Why Most People Fail to Save',
              body:
                  'The culprit is almost always the order of operations. People spend first and try to save whatever is left — which is usually nothing. The fix is mechanical: set up an automatic transfer to a separate savings account the same day your income arrives. You adapt your lifestyle to what remains, not the other way around.',
            ),
            ArticleSection(
              heading: 'Building Your Emergency Fund',
              body:
                  'An emergency fund is a liquid cash reserve of three to six months of essential expenses. It is not an investment — it lives in a regular savings or high-yield bank account, instantly accessible. Without it, any unexpected expense (medical bill, phone repair, job loss) forces you into debt. Calculate your monthly essentials (rent, food, transport, utilities) and set a target of 3× that figure as your Starter Emergency Fund.',
            ),
            ArticleSection(
              heading: 'The Power of Micro-Saving',
              body:
                  'You do not need large lump sums to save meaningfully. Saving Rs. 100 every day adds up to Rs. 36,500 in a year. Modern apps (including PennyPal) let you set daily or weekly micro-saving goals. When combined with automatic rounding-up of purchases to the nearest Rs. 10, the amounts accumulate without any manual effort or feeling of sacrifice.',
            ),
            ArticleSection(
              heading: 'Separate Accounts for Separate Goals',
              body:
                  'Psychologists call it "mental accounting" — we treat money differently based on which account it is in. Open a dedicated sub-account for each major goal: Emergency Fund, Vacation, Gadgets, Education. Label each account with its goal name. The simple act of labelling dramatically reduces the likelihood of withdrawing for non-goal spending.',
            ),
          ],
          actionSteps: [
            'Set up a standing order for 10% of income to transfer on payday.',
            'Calculate your monthly essential expenses and multiply by 3 for your emergency fund target.',
            'Open a separate labeled savings account in your bank app.',
            'Enable round-up savings in PennyPal settings.',
            'Set a daily micro-saving goal — even Rs. 50 counts.',
          ],
        ),

        LearningArticleModel(
          id: 'art_4',
          title: 'Financial Goals 101',
          duration: '7 min',
          level: 'Beginner',
          category: 'Saving',
          imageColor: AppColors.successGreen,
          backgroundColor: AppColors.successGreenLight,
          imageIcon: Icons.track_changes_rounded,
          imagePath: 'assets/images/saving_hero.jpg',
          summary:
              'Set SMART milestone targets for gadgets, travel, and personal investments that keep you motivated and on track.',
          keyTakeaways: [
            'SMART goals are Specific, Measurable, Achievable, Relevant, and Time-bound.',
            'Break a large goal into monthly milestones to maintain momentum.',
            'Visualizing progress is scientifically proven to boost follow-through.',
            'Automate contributions so the goal advances even when motivation dips.',
            'Celebrate milestones — positive reinforcement sustains long-term habits.',
          ],
          sections: [
            ArticleSection(
              heading: 'What Makes a Goal "SMART"?',
              body:
                  '"I want to save money" is not a goal — it is a wish. "I will save Rs. 60,000 for a new laptop by March 31st by putting Rs. 5,000 aside every month" is a SMART goal. Notice the five elements: it is Specific (laptop), Measurable (Rs. 60,000), Achievable (Rs. 5,000/month is realistic), Relevant (I need it for university), and Time-bound (March 31st). This structure transforms an intention into a plan.',
            ),
            ArticleSection(
              heading: 'Short vs. Medium vs. Long-Term Goals',
              body:
                  'Short-term goals (under 1 year): emergency fund, new phone, vacation. These should be in a plain savings account — no risk. Medium-term goals (1–5 years): a car, a house down-payment, postgraduate education. Consider a fixed deposit or low-risk investment for extra growth. Long-term goals (5+ years): retirement, children\'s education. Here, inflation is your enemy; only investment vehicles can outpace it.',
            ),
            ArticleSection(
              heading: 'The Progress Visualization Effect',
              body:
                  'Research in behavioral finance shows that people who see a visual progress indicator — like PennyPal\'s circular goal tracker — are 40% more likely to reach their savings target compared to those who only track numbers. The human brain is wired to complete incomplete things (the Zeigarnik effect). Use PennyPal\'s Goals screen to keep your milestones front and centre.',
            ),
          ],
          actionSteps: [
            'List 3 financial goals you have right now — any size is fine.',
            'Rewrite each goal in the SMART format.',
            'Calculate the monthly contribution required for each.',
            'Add each goal to PennyPal\'s Goals screen with a target date.',
            'Take a screenshot of your goals list and set it as your phone wallpaper.',
          ],
        ),

        // ── Basics ────────────────────────────────────────────────────────────────
        LearningArticleModel(
          id: 'art_5',
          title: 'Understand Your Spending',
          duration: '8 min',
          level: 'Intermediate',
          category: 'Basics',
          imageColor: AppColors.purple,
          backgroundColor: AppColors.purpleLight,
          imageIcon: Icons.pie_chart_rounded,
          imagePath: 'assets/images/budgeting_hero.jpg',
          summary:
              'How to spot hidden recurring subscriptions and identify unnecessary impulse buys before they drain your account.',
          keyTakeaways: [
            'The average person has 2–4 forgotten subscriptions costing Rs. 1,000+ monthly.',
            'Impulse buying is triggered by emotion — identifying triggers is the cure.',
            'A 24-hour waiting rule eliminates 80% of regret purchases.',
            'Categorized spending reports reveal patterns invisible to casual inspection.',
            'Weekly reviews prevent small leaks from becoming financial floods.',
          ],
          sections: [
            ArticleSection(
              heading: 'The Subscription Audit',
              body:
                  'Open your last three months of bank statements. Highlight every recurring charge — monthly, quarterly, or annual. You will likely find services you forgot you signed up for. Common culprits: streaming platforms, cloud storage, fitness apps, news subscriptions, and gaming passes. Calculate the annual cost of each and ask: "Did I use this at least once a week?" If not, cancel it immediately.',
            ),
            ArticleSection(
              heading: 'Impulse Buying: The Science',
              body:
                  'Impulse purchases activate the brain\'s reward centre (nucleus accumbens) in the same way as other pleasurable activities. Retailers engineer every element — checkout placement, limited-time offers, "last item in stock" warnings — to trigger this response before rational thought kicks in. Recognising the emotional state that precedes your impulse buys (boredom, stress, social envy) is the most effective counter-measure.',
            ),
            ArticleSection(
              heading: 'The 24-Hour Rule',
              body:
                  'For any unplanned purchase over Rs. 2,000, implement a mandatory 24-hour waiting period. Add it to a wishlist or take a screenshot. When 24 hours have passed, revisit the item. Studies show that the desire to buy drops by an average of 70% within that window when the item does not address a genuine need. The rule is simple and brutally effective.',
            ),
            ArticleSection(
              heading: 'Reading Your Spending Report',
              body:
                  'PennyPal\'s Reports screen generates a category breakdown of your monthly spending. Look for the category that surprises you most — it is almost always Food & Dining or Shopping. Compare the current month against the previous month. A rise of more than 20% in any category without a clear reason (festival season, medical need) is a red flag worth investigating.',
            ),
          ],
          actionSteps: [
            'Pull up your last three bank statements and list every recurring charge.',
            'Cancel any subscription you have not actively used in the past 30 days.',
            'Write down the last 3 impulse purchases — note what emotion preceded them.',
            'Add the 24-hour waiting rule to your phone as a sticky note reminder.',
            'Check the Reports screen in PennyPal weekly for spending anomalies.',
          ],
        ),

        LearningArticleModel(
          id: 'art_6',
          title: 'How Money Really Works',
          duration: '6 min',
          level: 'Beginner',
          category: 'Basics',
          imageColor: AppColors.shoppingOrange,
          backgroundColor: AppColors.shoppingOrangeLight,
          imageIcon: Icons.lightbulb_rounded,
          imagePath: 'assets/images/budgeting_hero.jpg',
          summary:
              'A plain-English primer on income, expenses, net worth, and why cash flow — not salary — determines financial freedom.',
          keyTakeaways: [
            'Net worth = Assets minus Liabilities — salary alone is irrelevant.',
            'Cash flow is the true measure of financial health at any moment.',
            'Assets put money in your pocket; liabilities take money out.',
            'Lifestyle inflation is the biggest wealth killer for rising earners.',
            'Financial literacy is a skill — it improves with deliberate practice.',
          ],
          sections: [
            ArticleSection(
              heading: 'Income vs. Wealth',
              body:
                  'A doctor earning Rs. 500,000 per month who spends Rs. 490,000 has less financial security than a teacher earning Rs. 80,000 who saves Rs. 20,000 every month. Income is the rate at which money flows in. Wealth is the accumulated result of income minus expenses over time. High income does not guarantee wealth; high savings rate does.',
            ),
            ArticleSection(
              heading: 'Assets vs. Liabilities',
              body:
                  'Robert Kiyosaki\'s definition from "Rich Dad Poor Dad" is practical: an asset puts money in your pocket; a liability takes money out. A rental property that earns more in rent than it costs in mortgage, maintenance, and taxes is an asset. A car that depreciates and requires insurance and fuel is a liability. Most consumer goods are liabilities — which is not inherently wrong, but awareness shapes spending decisions.',
            ),
            ArticleSection(
              heading: 'The Lifestyle Inflation Trap',
              body:
                  'When income rises, spending tends to rise proportionally — this is lifestyle inflation or "lifestyle creep." You get a raise and suddenly you need a bigger apartment, a newer phone, and more expensive restaurants. The result: your savings rate stays flat or shrinks. The antidote is to commit, in advance, to saving 50% of every income increase before adjusting lifestyle. You still enjoy the raise; you also build wealth.',
            ),
          ],
          actionSteps: [
            'Calculate your net worth today: list all assets (bank balance, investments) and liabilities (loans, credit card balances).',
            'Identify two things you own that are pure liabilities.',
            'Determine your current monthly savings rate (savings ÷ income × 100).',
            'Set a target savings rate that is 5% higher than your current one.',
            'Read one personal-finance article or chapter every week for the next month.',
          ],
        ),

        // ── Investing ─────────────────────────────────────────────────────────────
        LearningArticleModel(
          id: 'art_7',
          title: 'Investing for Beginners',
          duration: '10 min',
          level: 'Beginner',
          category: 'Investing',
          imageColor: AppColors.successGreen,
          backgroundColor: AppColors.successGreenLight,
          imageIcon: Icons.trending_up_rounded,
          imagePath: 'assets/images/investing_hero.jpg',
          summary:
              'Everything you need to know to make your first investment — from compound interest to mutual funds — without the jargon.',
          keyTakeaways: [
            'Compound interest is the eighth wonder of the world — start early.',
            'Diversification reduces risk without proportionally reducing returns.',
            'Index funds beat most actively managed funds over the long term.',
            'Time in the market beats timing the market — always.',
            'Only invest money you will not need for at least 3–5 years.',
          ],
          sections: [
            ArticleSection(
              heading: 'The Magic of Compound Interest',
              body:
                  'Compound interest means you earn returns not just on your original investment but on all the returns accumulated before. Rs. 10,000 invested at 12% annual return becomes Rs. 17,623 in 5 years, Rs. 31,058 in 10 years, and Rs. 96,463 in 25 years — with zero additional contributions. Starting at 22 instead of 32 can double your retirement wealth. The only input that matters more than return rate is time.',
            ),
            ArticleSection(
              heading: 'Risk vs. Return',
              body:
                  'Every investment involves a trade-off between expected return and risk (the possibility of losing money). Fixed deposits (FDs) offer predictable, guaranteed returns but trail inflation over the long term. Stocks offer higher potential returns but fluctuate daily. The appropriate mix depends on your time horizon and temperament. Younger investors with 10+ year horizons can tolerate — and should embrace — more equity exposure.',
            ),
            ArticleSection(
              heading: 'What Is a Mutual Fund?',
              body:
                  'A mutual fund pools money from thousands of investors to buy a diversified portfolio of stocks, bonds, or other assets, managed by a professional fund manager. The key advantage is instant diversification: instead of buying 50 individual stocks (expensive and complex), you buy one fund unit that represents all of them. Index funds are a subset that simply replicate a market index (like the KSE-100) — they charge lower fees and historically outperform most active funds.',
            ),
            ArticleSection(
              heading: 'How to Start with Rs. 1,000',
              body:
                  'You do not need large capital to begin. Many mutual fund platforms in Pakistan allow investments starting at Rs. 500–1,000 through monthly SIP (Systematic Investment Plan) arrangements. Open an account with a registered AMC (Asset Management Company), complete your KYC (CNIC + selfie), and set up a monthly SIP. The discipline of investing a fixed amount every month regardless of market conditions is called rupee-cost averaging — it eliminates the stress of timing the market.',
            ),
          ],
          actionSteps: [
            'Open a compound interest calculator and model Rs. 5,000/month for 10, 20, and 30 years.',
            'Look up one registered AMC in Pakistan and explore their fund offerings.',
            'Decide on an investment horizon (when will you need this money?).',
            'Open an investment account with KYC documents ready.',
            'Start a SIP of any amount — even Rs. 1,000 — this month.',
          ],
        ),

        // ── Credit ────────────────────────────────────────────────────────────────
        LearningArticleModel(
          id: 'art_8',
          title: 'Credit Scores Demystified',
          duration: '7 min',
          level: 'Intermediate',
          category: 'Credit',
          imageColor: AppColors.expenseRed,
          backgroundColor: AppColors.expenseRedLight,
          imageIcon: Icons.credit_score_rounded,
          imagePath: 'assets/images/credit_hero.jpg',
          summary:
              'What a credit score is, how it is calculated, why it matters for loans and housing, and five ways to improve yours.',
          keyTakeaways: [
            'A credit score is a 3-digit number (300–850) summarizing your credit history.',
            'Payment history (35%) is the single largest factor in your score.',
            'Keep credit utilization below 30% of your total credit limit.',
            'Every hard inquiry slightly lowers your score for 12 months.',
            'Building credit takes time — start early with a secured credit card.',
          ],
          sections: [
            ArticleSection(
              heading: 'What Is a Credit Score?',
              body:
                  'A credit score is a numerical representation of how reliably you have repaid borrowed money in the past. Lenders — banks, mortgage providers, car-loan companies — use it to predict how reliably you will repay in the future. A higher score unlocks lower interest rates, higher loan limits, and even better rental terms. In Pakistan, the eCIB (electronic Credit Information Bureau) maintained by SBP provides credit reports to registered institutions.',
            ),
            ArticleSection(
              heading: 'The Five Factors',
              body:
                  'Credit scores are calculated from five weighted factors: (1) Payment History (35%) — do you pay bills on time? (2) Credit Utilization (30%) — what percentage of available credit are you using? (3) Length of Credit History (15%) — how long have your accounts been open? (4) Credit Mix (10%) — do you have a variety of credit types? (5) New Credit (10%) — how recently have you applied for credit? Each factor offers a lever you can pull to improve your score.',
            ),
            ArticleSection(
              heading: 'Why Utilization Matters So Much',
              body:
                  'Credit utilization is the ratio of your outstanding credit card balance to your total credit limit. If your limit is Rs. 100,000 and your balance is Rs. 60,000, your utilization is 60% — too high. Lenders see high utilization as a sign of financial stress. Keeping it below 30% signals disciplined credit management. The easiest way to improve utilization instantly is to pay down balances or request a credit limit increase.',
            ),
            ArticleSection(
              heading: 'Building Credit from Zero',
              body:
                  'If you have no credit history, lenders have no data to evaluate you — which is paradoxically a barrier to getting credit. Solutions: (1) Apply for a secured credit card (you deposit a fixed amount as collateral). (2) Become an authorized user on a family member\'s card. (3) Take a small personal loan and repay it perfectly. (4) Ensure utility bills and phone contracts are in your name and paid on time.',
            ),
          ],
          actionSteps: [
            'Check if your bank offers a credit score tracker in their app.',
            'List all your credit cards and calculate your current utilization ratio.',
            'Set up automatic minimum payments on every card to avoid missed payments.',
            'If you have no credit history, research secured credit card options at your bank.',
            'Set a calendar reminder to review your credit report every six months.',
          ],
        ),

        // ── Taxes ─────────────────────────────────────────────────────────────────
        LearningArticleModel(
          id: 'art_9',
          title: 'Tax Basics for Young Earners',
          duration: '9 min',
          level: 'Intermediate',
          category: 'Taxes',
          imageColor: AppColors.purple,
          backgroundColor: AppColors.purpleLight,
          imageIcon: Icons.receipt_long_rounded,
          imagePath: 'assets/images/credit_hero.jpg',
          summary:
              'A beginner-friendly guide to income tax brackets, deductions you might be missing, and how to file your first return.',
          keyTakeaways: [
            'Pakistan uses a progressive tax system — higher income, higher rate.',
            'Filing a tax return is mandatory once income exceeds Rs. 600,000/year.',
            'Filers receive lower withholding tax rates on banking transactions.',
            'Allowable deductions (Zakat, charity, investments) reduce taxable income.',
            'Missing the filing deadline (September 30) results in late fees and penalties.',
          ],
          sections: [
            ArticleSection(
              heading: 'How Income Tax Works in Pakistan',
              body:
                  'Pakistan\'s Federal Board of Revenue (FBR) administers income tax under the Income Tax Ordinance 2001. The system is progressive: the first Rs. 600,000 of annual income is tax-free. Income from Rs. 600,001 to Rs. 1,200,000 is taxed at 5%, and higher brackets attract higher rates up to 35%. Your employer deducts tax at source (withholding tax) from salary — but you still need to file a return to reconcile and claim deductions.',
            ),
            ArticleSection(
              heading: 'Why Registering as a Filer Matters',
              body:
                  'Being a "filer" (having an active tax return on record with FBR) entitles you to significantly lower withholding tax rates on banking transactions, property purchases, vehicle registration, and foreign exchange. Non-filers pay double the rate in many categories. Registering via the IRIS portal (iris.fbr.gov.pk) takes less than 30 minutes with your CNIC and creates your NTN (National Tax Number) instantly.',
            ),
            ArticleSection(
              heading: 'Deductions That Save You Money',
              body:
                  'Several expenses are deductible from your taxable income, directly reducing the tax you owe: (1) Zakat paid on savings bank accounts. (2) Donations to FBR-approved charitable organisations (up to 30% of taxable income). (3) Contributions to approved pension funds (up to 20% of income). (4) Medical allowance (up to Rs. 10,000/month if employer-certified). (5) Education expenses for dependent children at approved institutions.',
            ),
            ArticleSection(
              heading: 'Filing Your First Return',
              body:
                  'To file: (1) Gather documents: salary slips, bank statements, CNIC. (2) Log into iris.fbr.gov.pk. (3) Select "Declaration > 114(1) Return of Income." (4) Enter income, deductions, and assets. (5) Verify and submit. The deadline is September 30 each year. First-time filers often hire a tax consultant for Rs. 1,000–3,000 — worth it for the peace of mind and correct deductions.',
            ),
          ],
          actionSteps: [
            'Check your NTN status on iris.fbr.gov.pk using your CNIC.',
            'If unregistered, complete the free IRIS registration online.',
            'Collect your salary slips, bank certificate, and Zakat certificate (if any).',
            'Calculate if your annual income exceeds Rs. 600,000 — if so, filing is mandatory.',
            'Set a calendar alarm for September 30 as your filing deadline every year.',
          ],
        ),
      ];
}
