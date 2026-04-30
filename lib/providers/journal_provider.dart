import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

final journalProvider = Provider<List<Article>>((ref) {
  return [
    Article(
      id: '1',
      title: 'Top 5 Supplements for Muscle Recovery',
      summary: 'Discover the best supplements to help you recover faster after an intense workout session.',
      content: 'Muscle recovery is just as important as the workout itself. Without proper recovery, your muscles cannot repair and grow stronger. Here are the top 5 supplements to accelerate your recovery:\n\n1. Whey Protein Isolate: The gold standard for post-workout recovery. It provides a rapid influx of amino acids to jumpstart muscle protein synthesis.\n\n2. BCAAs (Branched-Chain Amino Acids): Leucine, isoleucine, and valine help reduce muscle soreness and fatigue.\n\n3. Creatine Monohydrate: Not just for strength, creatine replenishes ATP stores, allowing for quicker recovery between sets and sessions.\n\n4. L-Glutamine: An amino acid that helps rebuild muscle tissue and supports the immune system, which can be suppressed after intense training.\n\n5. Omega-3 Fish Oil: Helps reduce exercise-induced inflammation and muscle soreness.',
      imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?q=80&w=800',
      category: 'Supplements',
      author: 'Dr. Sarah Jenkins',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      readTimeMinutes: 4,
    ),
    Article(
      id: '2',
      title: 'The Truth About Pre-Workouts',
      summary: 'Are pre-workout supplements really necessary? We break down the science.',
      content: 'Pre-workout supplements are incredibly popular, but are they necessary? Let\'s break down what they actually do.\n\nMost pre-workouts contain a blend of caffeine for energy, beta-alanine for endurance (which causes that tingling sensation), and nitric oxide boosters like L-Citrulline for better blood flow and "pumps".\n\nWhile not strictly necessary for a good workout, they can provide a significant performance boost on days when you are feeling sluggish or need an extra push for a heavy lifting session. However, it is important to cycle them to avoid building up a caffeine tolerance.',
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=800',
      category: 'Nutrition',
      author: 'Alex Carter',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      readTimeMinutes: 3,
    ),
    Article(
      id: '3',
      title: 'Beginner\'s Guide to Macronutrients',
      summary: 'Learn how to balance your proteins, carbs, and fats for optimal performance.',
      content: 'Macronutrients, or "macros", are the three main components of our diet: proteins, carbohydrates, and fats. Understanding how to balance them is key to reaching any fitness goal.\n\nProteins (4 calories/gram): Essential for building and repairing muscle tissue. Aim for 0.8-1.2 grams per pound of body weight if you are active.\n\nCarbohydrates (4 calories/gram): Your body\'s primary energy source. Focus on complex carbs like sweet potatoes and oats for sustained energy.\n\nFats (9 calories/gram): Crucial for hormone production and joint health. Include healthy sources like avocados, nuts, and olive oil.\n\nThe ideal ratio depends on your specific goals—whether it is fat loss, muscle gain, or maintenance.',
      imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=800',
      category: 'Diet',
      author: 'Emma Wilson',
      publishedAt: DateTime.now().subtract(const Duration(days: 10)),
      readTimeMinutes: 5,
    ),
    Article(
      id: '4',
      title: 'How to Break Through a Plateu',
      summary: 'Stuck at the same weight? Try these 3 training techniques.',
      content: 'Hitting a plateau is frustrating but completely normal. When your body adapts to a stimulus, progress stalls. Here is how to break through:\n\n1. Progressive Overload: Ensure you are consistently increasing the weight, reps, or volume over time.\n\n2. Change Your Rep Ranges: If you always train in the 8-12 rep range, try a strength phase of 4-6 reps to shock your central nervous system.\n\n3. Deload Week: Sometimes less is more. Taking a week to lift at 50-60% of your normal intensity allows your muscles and joints to fully recover, setting you up for future gains.',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800',
      category: 'Training',
      author: 'Marcus Johnson',
      publishedAt: DateTime.now().subtract(const Duration(days: 15)),
      readTimeMinutes: 6,
    ),
  ];
});

final journalCategoryProvider = Provider<List<String>>((ref) {
  final articles = ref.watch(journalProvider);
  return ['All', ...articles.map((a) => a.category).toSet()];
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredArticlesProvider = Provider<List<Article>>((ref) {
  final articles = ref.watch(journalProvider);
  final category = ref.watch(selectedCategoryProvider);
  
  if (category == 'All') return articles;
  return articles.where((a) => a.category == category).toList();
});
