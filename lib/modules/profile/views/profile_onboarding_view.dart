import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/common_button.dart';
import '../widgets/demographics_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/address_section.dart';
import '../widgets/education_section.dart';

class ProfileOnboardingView extends StatefulWidget {
  const ProfileOnboardingView({super.key});

  @override
  State<ProfileOnboardingView> createState() => _ProfileOnboardingViewState();
}

class _ProfileOnboardingViewState extends State<ProfileOnboardingView> {
  final ProfileController controller = Get.find<ProfileController>();
  final PageController _pageController = PageController();
  int _activeStep = 0;
  final int _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    bool isValid = false;
    switch (_activeStep) {
      case 0:
        isValid = controller.validateDemographicsStep();
        break;
      case 1:
        isValid = controller.validateContactStep();
        break;
      case 2:
        isValid = controller.validateAddressStep();
        break;
      case 3:
        isValid = controller.validateEducationStep();
        break;
      default:
        isValid = true;
    }

    if (!isValid) return;

    if (_activeStep < _totalSteps - 1) {
      setState(() {
        _activeStep++;
      });
      _pageController.animateToPage(
        _activeStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      controller.updateStudentProfile(isOnboarding: true);
    }
  }

  void _prevStep() {
    if (_activeStep > 0) {
      setState(() {
        _activeStep--;
      });
      _pageController.animateToPage(
        _activeStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;
    final borderColor = Theme.of(context).colorScheme.outline;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Row(
                  children: List.generate(_totalSteps, (index) {
                    final isActive = index <= _activeStep;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          color: isActive ? primaryColor : borderColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_activeStep + 1} of $_totalSteps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      _getStepTitle(_activeStep),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: DemographicsSection(controller: controller),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ContactSection(controller: controller),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AddressSection(controller: controller),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: EducationSection(controller: controller),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (_activeStep > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: primaryColor),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: CommonButton(
                        text: _activeStep == _totalSteps - 1 ? 'Submit' : 'Continue',
                        isLoading: controller.isUpdatingStudentProfile.value,
                        onPressed: _nextStep,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        height: 54,
                        borderRadius: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Demographics';
      case 1:
        return 'Contact & Family';
      case 2:
        return 'Address';
      case 3:
        return 'Education';
      default:
        return '';
    }
  }
}
