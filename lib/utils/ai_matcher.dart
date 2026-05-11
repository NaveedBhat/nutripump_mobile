import '../models/product.dart';

class TasteProfile {
  final String morning; // "sweet" | "savory" | "fast"
  final String texture; // "smooth" | "crunchy" | "stone-ground"
  final String lifestyle; // "energy" | "relaxation" | "immunity"
  final String vibe; // "discovery" | "heritage" | "artisanal"

  const TasteProfile({
    required this.morning,
    required this.texture,
    required this.lifestyle,
    required this.vibe,
  });

  TasteProfile copyWith({
    String? morning,
    String? texture,
    String? lifestyle,
    String? vibe,
  }) {
    return TasteProfile(
      morning: morning ?? this.morning,
      texture: texture ?? this.texture,
      lifestyle: lifestyle ?? this.lifestyle,
      vibe: vibe ?? this.vibe,
    );
  }
}

class ProductScore {
  final Product product;
  final double score;

  const ProductScore(this.product, this.score);
}

class AiMatcher {
  static List<Product> scoreProfileMatch(
      List<Product> products, TasteProfile profile) {
    final scored = products.map((p) {
      double score = 0;
      final pTags = p.tags.map((t) => t.toLowerCase()).toList();
      final pBenefits = (p.benefits ?? []).map((b) => b.toLowerCase()).toList();
      final pCategory = p.category.toLowerCase();

      // 1. Morning Ritual / Flavor mapping
      if (profile.morning == "sweet") {
        if (p.flavorProfile == "sweet" ||
            pCategory.contains("honey") ||
            pTags.contains("sweet")) {
          score += 5;
        }
      } else if (profile.morning == "savory") {
        if (p.flavorProfile == "savory" ||
            pTags.contains("savory") ||
            pTags.contains("salty")) {
          score += 5;
        }
      } else if (p.flavorProfile == "balanced" || profile.morning == "fast") {
        score += 2;
      }

      // 2. Texture mapping (Prioritize high-fidelity texture match)
      if (p.texture != null && p.texture == profile.texture) {
        score += 6;
      } else if (pTags.contains(profile.texture)) {
        score += 4;
      } else if (profile.texture == "stone-ground" &&
          (pTags.contains("crunchy") || p.texture == "crunchy")) {
        score += 2;
      }

      // 3. Lifestyle mapping
      if (profile.lifestyle == "energy") {
        if (pTags.contains("energy") || pBenefits.contains("high protein")) {
          score += 3;
        }
      } else if (profile.lifestyle == "relaxation") {
        if (pTags.contains("relaxation") || pCategory.contains("honey")) {
          score += 2;
        }
      } else if (profile.lifestyle == "immunity") {
        if (pTags.contains("immunity") || pBenefits.contains("immunity")) {
          score += 5;
        }
      }

      // 4. Vibe mapping (Personality match)
      if (p.vibe != null && p.vibe == profile.vibe) {
        score += 4;
      } else if (pTags.contains(profile.vibe)) {
        score += 2;
      }

      if (p.featured) {
        score += 1;
      }

      return ProductScore(p, score);
    }).toList();

    scored.retainWhere((s) => s.score > 0);
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((s) => s.product).toList();
  }

  static String getRecommendedMessage(
      TasteProfile profile, Product topProduct) {
    final messages = {
      "sweet":
          "Since you love a sweet morning ritual, we've found your perfect match from the Himalayan valleys.",
      "savory":
          "For your savory palette, this artisanal treasure from Srinagar is our top recommendation.",
      "fast":
          "Always on the go? This nutrient-dense match will keep you fueled throughout your day.",
    };

    final intro = messages[profile.morning] ??
        "We've analyzed your taste profile and found your Himalayan Soul Match.";
    return "$intro Meet **${topProduct.name}** — handcrafted specifically for your ${profile.lifestyle} lifestyle and ${profile.texture} texture preference.";
  }
}
