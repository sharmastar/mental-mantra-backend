import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/nutrition_data.dart';

class NutritionState {
  final WellnessCategory selectedCategory;
  final int waterGlasses;

  const NutritionState({
    this.selectedCategory = WellnessCategory.hydration,
    this.waterGlasses = 0,
  });

  NutritionState copyWith(
      {WellnessCategory? selectedCategory, int? waterGlasses}) {
    return NutritionState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      waterGlasses: waterGlasses ?? this.waterGlasses,
    );
  }
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier() : super(const NutritionState());

  void selectCategory(WellnessCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setWaterGlasses(int count) {
    state = state.copyWith(waterGlasses: count.clamp(0, 8));
  }

  void incrementWater() {
    if (state.waterGlasses < 8) {
      state = state.copyWith(waterGlasses: state.waterGlasses + 1);
    }
  }

  void decrementWater() {
    if (state.waterGlasses > 0) {
      state = state.copyWith(waterGlasses: state.waterGlasses - 1);
    }
  }
}

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  return NutritionNotifier();
});
