// JavaScript for the feature slider
document.addEventListener('DOMContentLoaded', () => {
    const sliderTrack = document.querySelector('.slider-track');
    const sliderContainer = document.querySelector('.slider-container');
    const sliderPrevBtn = document.querySelector('.slider-prev');
    const sliderNextBtn = document.querySelector('.slider-next');
    const featureCards = document.querySelectorAll('.feature-item');

    let currentIndex = 0;
    const cardsPerPage = 3; // Number of cards visible at once
    const slideInterval = 5000; // Time in ms for auto slide (increased from 3000 to 5000)
    let autoSlideTimer;

    function updateSlider() {
        const cardWidth = featureCards[0].offsetWidth + 20; // Card width + gap
        const offset = -currentIndex * cardWidth;
        sliderTrack.style.transform = `translateX(${offset}px)`;
    }

    function startAutoSlide() {
        autoSlideTimer = setInterval(() => {
            if (currentIndex < featureCards.length - cardsPerPage) {
                currentIndex++;
            } else {
                currentIndex = 0; // Loop back to the start
            }
            updateSlider();
        }, slideInterval);
    }

    function stopAutoSlide() {
        clearInterval(autoSlideTimer);
    }

    sliderNextBtn.addEventListener('click', () => {
        stopAutoSlide();
        if (currentIndex < featureCards.length - cardsPerPage) {
            currentIndex++;
        } else {
            currentIndex = 0; // Loop back to the start
        }
        updateSlider();
        startAutoSlide();
    });

    sliderPrevBtn.addEventListener('click', () => {
        stopAutoSlide();
        if (currentIndex > 0) {
            currentIndex--;
        } else {
            currentIndex = featureCards.length - cardsPerPage; // Loop to the end
        }
        updateSlider();
        startAutoSlide();
    });

    sliderContainer.addEventListener('mouseenter', stopAutoSlide);
    sliderContainer.addEventListener('mouseleave', startAutoSlide);

    // Initial update and start auto slide
    updateSlider();
    startAutoSlide();
}); 