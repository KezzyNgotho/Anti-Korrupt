<script>
  import { onMount } from 'svelte';
  import logo from '../../../public/image8.png';

  let activeSection = 'courses';
  let seeAll = false; // Toggle for "See All" courses

  let userProgress = {
    'introduction-to-ai-and-blockchain': 0,
    'advanced-ai-techniques': 70,
    'blockchain-development-essentials': 45,
    'defi-and-fintech': 30,
    'ai-ethics-and-governance': 10,
  };

  let quizzes = [
    { title: "AI Basics Quiz", description: "Test your knowledge of AI fundamentals.", questions: 10 },
    { title: "Blockchain 101 Quiz", description: "How well do you know blockchain technology?", questions: 12 },
    { title: "DeFi & Fintech Quiz", description: "Assess your understanding of decentralized finance and fintech.", questions: 8 },
  ];

  // Function to toggle 'See All' visibility
  function toggleSeeAll() {
    seeAll = !seeAll;
  }

  // Function to handle navigation to different sections
  function handleNavClick(section) {
    activeSection = section;
    document.getElementById(section)?.scrollIntoView({ behavior: 'smooth' });
  }

  // Start learning redirects to the chatbots section
  function startLearning(courseId) {
    handleNavClick('chatbots');
  }

  // Function to start the quiz
  function startQuiz(quiz) {
    console.log("Starting quiz:", quiz.title);
  }

  onMount(() => {
    handleNavClick('courses'); // Set default section to be displayed on load
  });
</script>

<link
  rel="stylesheet"
  href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css"
/>

<!-- Navbar -->
<header class="bg-gradient-to-r from-[#0f535c] to-[#38a0ac] text-white py-4 px-6 flex flex-col md:flex-row items-center justify-between shadow-lg fixed top-0 w-full z-50">
  <div class="flex items-center space-x-4 w-full md:w-auto">
    <a href="/" class="flex items-center space-x-2">
      <img src={logo} alt="LLM Logo" class="w-12 h-12 sm:w-14 sm:h-14 rounded-full border-4 border-blue-200 transition-transform transform hover:scale-110 duration-300" />
      <h1 class="text-xl sm:text-2xl md:text-3xl font-bold">LLMVerse</h1>
    </a>
  </div>

  <!-- Center Links (Desktop) -->
  <nav class="hidden md:flex flex-grow justify-center space-x-6 mt-4 md:mt-0">
    {#each ['Courses', 'Chatbots', 'Quizzes', 'Contact'] as link}
      <a
        on:click={() => handleNavClick(link.toLowerCase())}
        class="text-white hover:text-blue-300 border-b-2 border-transparent hover:border-white px-4 py-2 transition-all duration-300 cursor-pointer"
      >
        {link}
      </a>
    {/each}
  </nav>

  <!-- Right Section Buttons -->
  <div class="flex space-x-4 mt-4 md:mt-0">
    <button 
      on:click={() => handleNavClick('courses')}
      class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
      Get Started 🚀
    </button>
    <button 
      on:click={() => handleNavClick('partner')}
      class="bg-transparent border border-blue-200 text-white px-4 py-2 rounded-full shadow-md hover:bg-blue-300 hover:text-[#023e8a] transition-all duration-300 transform hover:scale-105">
      Partner with Us 🤝
    </button>
  </div>
</header>

<!-- Main Content -->
<div class="pt-20">
  <!-- Courses Section -->
  <section id="courses" class="py-16 bg-gray-50" class:hidden={activeSection !== 'courses'}>
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0f535c] mb-8">Available Courses</h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">Explore our curated courses designed to deepen your understanding of AI and blockchain technologies.</p>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <!-- Display main courses -->
        {#each [
          { id: 'introduction-to-ai-and-blockchain', title: 'Introduction to AI and Blockchain', description: 'Learn the fundamentals of AI and blockchain technology, including their applications and impact on various industries.' },
          { id: 'advanced-ai-techniques', title: 'Advanced AI Techniques', description: 'Dive deeper into advanced AI techniques, including machine learning, deep learning, and neural networks.' },
          { id: 'blockchain-development-essentials', title: 'Blockchain Development Essentials', description: 'Understand the essentials of blockchain development, including smart contracts, decentralized apps (DApps), and blockchain architecture.' }
        ] as { id, title, description }}
          <div class="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105">
            <h3 class="text-xl font-semibold text-[#023e8a] mb-4">{title}</h3>
            <p class="text-gray-800 mb-4">{description}</p>
            <div class="h-2 bg-gray-200 rounded-full mb-4">
              <div class="h-full bg-[#023e8a] rounded-full" style="width: {userProgress[id] || 0}%"></div>
            </div>
            <div class="flex justify-center space-x-4">
              <button
                on:click={() => startLearning(id)}
                class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
                Start Learning
              </button>
              <button
                class="bg-transparent border border-[#023e8a] text-[#023e8a] px-4 py-2 rounded-full shadow-md hover:bg-[#023e8a] hover:text-white transition-all duration-300 transform hover:scale-105">
                View Details
              </button>
            </div>
          </div>
        {/each}

        <!-- "See All" button -->
        <div class="col-span-full text-center mt-6">
          <button on:click={toggleSeeAll} class="text-[#023e8a] hover:underline">
            {seeAll ? 'Show Less' : 'See All'}
          </button>
        </div>
      </div>

      <!-- Full course list (shown when "See All" is clicked) -->
      {#if seeAll}
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
          {#each [
            { id: 'defi-and-fintech', title: 'DeFi and Fintech', description: 'Explore the decentralized finance (DeFi) space and the future of fintech with blockchain.' },
            { id: 'ai-ethics-and-governance', title: 'AI Ethics and Governance', description: 'Understand the ethical implications of AI and how governance frameworks are shaping its development.' }
          ] as { id, title, description }}
            <div class="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105">
              <h3 class="text-xl font-semibold text-[#023e8a] mb-4">{title}</h3>
              <p class="text-gray-800 mb-4">{description}</p>
              <div class="h-2 bg-gray-200 rounded-full mb-4">
                <div class="h-full bg-[#023e8a] rounded-full" style="width: {userProgress[id] || 0}%"></div>
              </div>
              <div class="flex justify-center space-x-4">
                <button
                  on:click={() => startLearning(id)}
                  class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
                  Start Learning
                </button>
                <button
                  class="bg-transparent border border-[#023e8a] text-[#023e8a] px-4 py-2 rounded-full shadow-md hover:bg-[#023e8a] hover:text-white transition-all duration-300 transform hover:scale-105">
                  View Details
                </button>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </section>

  <!-- Quizzes Section -->
  <section id="quizzes" class="py-16 bg-gray-50" class:hidden={activeSection !== 'quizzes'}>
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0f535c] mb-8">Quizzes</h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">Test your knowledge and skills with our challenging quizzes.</p>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {#each quizzes as quiz}
          <div class="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105">
            <h3 class="text-xl font-semibold text-[#023e8a] mb-4">{quiz.title}</h3>
            <p class="text-gray-800 mb-4">{quiz.description}</p>
            <p class="text-gray-500 text-sm mb-4">{quiz.questions} questions</p>
            <button
              on:click={() => startQuiz(quiz)}
              class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
              Start Quiz
            </button>
          </div>
        {/each}
      </div>
    </div>
  </section>

  <!-- Chatbots Section -->
  <section id="chatbots" class="py-16 bg-gray-50" class:hidden={activeSection !== 'chatbots'}>
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0f535c] mb-8">AI-Powered Chatbots</h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">Interact with AI-driven chatbots to enhance your learning experience.</p>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <!-- Example chatbots, you can populate this section with real chatbots -->
        <div class="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105">
          <h3 class="text-xl font-semibold text-[#023e8a] mb-4">AI Learning Assistant</h3>
          <p class="text-gray-800 mb-4">Your AI-powered companion for personalized learning recommendations.</p>
          <button
            class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
            Chat Now
          </button>
        </div>
        <div class="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105">
          <h3 class="text-xl font-semibold text-[#023e8a] mb-4">Blockchain Mentor Bot</h3>
          <p class="text-gray-800 mb-4">Get answers to your blockchain-related questions from an AI expert.</p>
          <button
            class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
            Chat Now
          </button>
        </div>
      </div>
    </div>
  </section>

  <!-- Contact Section -->
  <section id="contact" class="py-16 bg-white" class:hidden={activeSection !== 'contact'}>
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0f535c] mb-8">Contact Us</h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">We'd love to hear from you! Reach out to us for any questions, suggestions, or partnership opportunities.</p>
      <div class="flex justify-center space-x-4">
        <button
          class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
          Email Us
        </button>
        <button
          class="bg-transparent border border-[#023e8a] text-[#023e8a] px-4 py-2 rounded-full shadow-md hover:bg-[#023e8a] hover:text-white transition-all duration-300 transform hover:scale-105">
          Call Us
        </button>
      </div>
    </div>
  </section>
</div>