<script>
  // @ts-nocheck
  
  import { onMount } from 'svelte';
  import logo from '../../../public/image8.png';
  import Modal from './Modal1.svelte'; // Ensure Modal.svelte is correctly imported
  import { HttpAgent, Actor } from '@dfinity/agent';
  import { idlFactory as DevinciIDL } from '/home/keziah/PRETORIA/Hackathon202409AI/src/declarations/DeVinci_backend';
  
  let activeSection = 'courses'; // Default section
  let selectedAnswers = {}; // Store selected answers for each quiz

  let currentLink = 'courses';
  let selectedSort = 'default';
  let courses = [];
  let filteredCourses = [];
  let courseCanister;
  let Devincibackend;
  let errorMessage = '';
  let seeAll = false;
  let activeTab = 'overview';
  let selectedReward = '';
  let userTokens = 50;
  let quizTimer = 60;
  export let courseId = '';
  let selectedCourseId;
  export let isActive = false;
  
  // Sample data for leaderboard and top users
  let leaderboard = [
      { name: 'Alice', avatar: 'https://via.placeholder.com/40', score: 120 },
      { name: 'Bob', avatar: 'https://via.placeholder.com/40', score: 110 },
      { name: 'Charlie', avatar: 'https://via.placeholder.com/40', score: 100 },
      { name: 'Dave', avatar: 'https://via.placeholder.com/40', score: 90 },
      { name: 'Eve', avatar: 'https://via.placeholder.com/40', score: 80 },
  ];
  
  let topUsers = [
      { rank: 1, name: 'Alice', avatar: 'https://via.placeholder.com/40', score: 120 },
      { rank: 2, name: 'Bob', avatar: 'https://via.placeholder.com/40', score: 110 },
      { rank: 3, name: 'Charlie', avatar: 'https://via.placeholder.com/40', score: 100 },
  ];
  
  let userProgressPercentage = 75;
  let timeFrame = 'weekly';
  let quizzes = "";
  let questions = [];
  let userProgress = {
      'introduction-to-ai-and-blockchain': 0,
      'advanced-ai-techniques': 70,
      'blockchain-development-essentials': 45,
  };
  
  let recentTokens = [
      'Completed AI Basics Quiz: +10 tokens',
      'Completed Blockchain 101 Quiz: +12 tokens',
      'Completed DeFi & Fintech Quiz: +8 tokens',
  ];
  
  let rewards = [
      'Free Course Access',
      'Exclusive NFT Badge',
      'One-on-One Mentor Session',
  ];
  
  let chatHistory = [
      { date: '2024-09-01', topic: 'Customer Support' },
      { date: '2024-08-15', topic: 'Learning Assistance' },
  ];
  
  let searchQuery = '';
  let selectedTag = 'All';
  let showModal = false;
  let modalContent = {};
  let tags = ['All', 'AI', 'Blockchain', 'DeFi', 'Fintech', 'Machine Learning', 'Ethics', 'Beginner', 'Intermediate', 'Advanced'];
  
  // Function to handle navigation clicks
  function handleNavClick(section) {
      activeSection = section;
      document.getElementById(section)?.scrollIntoView({ behavior: 'smooth' });
  }
  
  // Backend initialization
  async function initializeBackend() {
      try {
          const agent = new HttpAgent({
              host: "https://ic0.app" // Use this for the Internet Computer mainnet
          });
  
          if (process.env.NODE_ENV !== "production") {
              await agent.fetchRootKey();
          }
  
          Devincibackend = Actor.createActor(DevinciIDL, {
              agent,
              canisterId: "pq6ox-maaaa-aaaak-albia-cai", // Replace with your actual canister ID
          });
  
          console.log("Backend initialized successfully.");
      } catch (error) {
          console.error("Error initializing backend:", error);
          errorMessage = `Error initializing backend: ${error.message}`;
      }
  }
  
  // Fetch courses from the backend
  async function fetchCourses() {
      try {
          const response = await Devincibackend.listCourses();
          courses = response; // Store the fetched courses
          filteredCourses = courses; // Initialize filteredCourses
          tags = [...new Set(response.map(course => course.tag))]; // Assuming each course has a tag property
          filterCourses();
      } catch (error) {
          console.error("Error fetching courses:", error);
          errorMessage = `Error fetching courses: ${error.message}`;
      }
  }
  
  // Filtered courses based on search query and selected tag
  $: filteredCourses = courses.filter(course => {
      const matchesSearch = course.title.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesTag = selectedTag === 'All' || course.tags.includes(selectedTag);
      return matchesSearch && matchesTag;
  }).sort((a, b) => {
      if (selectedSort === 'rating') return b.rating - a.rating;
      if (selectedSort === 'progress') return (userProgress[b.id] || 0) - (userProgress[a.id] || 0);
      return 0; // default
  });
  
  // Function to toggle See All Courses
  function toggleSeeAll() {
      seeAll = !seeAll;
  }
  
  // Handle Tab Change in Rewards Section
  const handleTabChange = (tab) => {
      activeTab = tab;
  };
// Fetch Random Questions for a Course
// Fetch Questions for a Course
// Fetch Questions for a Course
 // Fetch Questions for a Course


 function serializeBigInts(data) {
  if (Array.isArray(data)) {
    return data.map(item => serializeBigInts(item));
  } else if (typeof data === 'object' && data !== null) {
    return Object.fromEntries(
      Object.entries(data).map(([key, value]) => [
        key,
        typeof value === 'bigint' ? value.toString() : serializeBigInts(value),
      ])
    );
  }
  return data; // return primitive values as is
}


async function fetchQuizzesForCourse(courseId) {
  if (!courseId) {
    console.error("Invalid courseId:", courseId);
    return;
  }
  console.log("Fetching quizzes for course ID:", courseId);
  try {
    const result = await Devincibackend.getRandomCourseQuestions(courseId, 10);
    console.log("Quizzes received for course ID", courseId, ":", result);

    if (result.err) {
      console.error('Error fetching quizzes:', result.err);
      quizzes = []; // Reset quizzes if there's an error
      return; // Exit the function early
    }

    // Serialize BigInt properties if necessary
    const serializedQuizzes = serializeBigInts(result.ok);
    quizzes = serializedQuizzes.map(quiz => ({
      id: quiz.id, // Assuming this is now a string
      description: quiz.description,
      options: quiz.options.map(option => ({
        text: option.description || "No description available", // Access description
        id: option.option // Include the option number if needed
      })),
    })) || []; // Ensure quizzes is an array

    // Log quizzes to ensure they are correctly formatted
    quizzes.forEach((quiz) => {
      console.log(`Quiz ID: ${quiz.id}, Description: ${quiz.description}, Options: ${JSON.stringify(quiz.options)}`);
    });

  } catch (error) {
    console.error('Error fetching quizzes:', error.message || error);
    quizzes = []; // Reset quizzes if there's an error
  }
}

  function startQuiz(quizId) {
    // Logic to start the quiz, maybe redirect or open a new component
    console.log(`Starting quiz with ID: ${quizId}`);
  }

 
  
    // Handle course selection
    async function handleCourseChange() {
        if (selectedCourseId) {
            await fetchQuizzesForCourse(selectedCourseId, 10); // Fetch 10 questions
        }
    }

    // Optionally, you can fetch questions when the component mounts
   /*  onMount(() => {
        // Example: Automatically fetch questions for the default course when the component mounts
        if (selectedCourseId) {
            fetchQuizzesForCourse(selectedCourseId, 10);
        }
    }); */

   

// Handle course selection
// Handle course selection\


  
  // Open Modal for Course
  function openModal(course) {
      modalContent = course;
      showModal = true;
  }
  
  // Close Modal
  function closeModal() {
      showModal = false;
      modalContent = {};
  }
  
  // On Mount, initialize backend and fetch courses
  onMount(async () => {
      console.log('Component mounted, fetching courses...');
      await initializeBackend();
      await fetchCourses();
  });
  </script>
  
  <!-- Add your HTML template below -->
  

<header class="bg-gradient-to-r from-[#0f535c] to-[#38a0ac] text-white py-4 px-6 flex flex-col md:flex-row items-center justify-between shadow-lg fixed top-0 w-full z-50">
  <div class="flex items-center space-x-4">
    <a href="/" class="flex items-center space-x-2">
      <img src={logo} alt="LLM Logo" class="w-10 h-10 sm:w-14 sm:h-14 rounded-full border-4 border-blue-200 transition-transform transform hover:scale-110 duration-300" />
      <h1 class="text-xl sm:text-2xl font-bold">LLMVerse</h1>
    </a>
  </div>

  <!-- Center Links (Desktop) -->
  <nav class="hidden md:flex flex-grow justify-center space-x-6 mt-4 md:mt-0">
    {#each ['Courses', 'Chatbots', 'Quizzes', 'Contact'] as link}
    <a
    on:click={() => handleNavClick(link.toLowerCase())}
    class={`text-gray-800 hover:text-[#0077b6] transition duration-300 font-semibold text-lg border-b-2 border-[#0077b6]`}
    aria-label={link}>
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
      on:click={() => handleNavClick('rewards')}
      class="bg-transparent border border-blue-200 text-white px-4 py-2 rounded-full shadow-md hover:bg-blue-300 hover:text-[#023e8a] transition-all duration-300 transform hover:scale-105">
      Rewards 🤝
    </button>
  </div>
</header>

<!-- Main Content -->
<main class="pt-20"> <!-- Add padding-top to offset the fixed navbar -->
  
  <!-- Courses Section -->
 <!-- <section id="start-learning" class="py-16 bg-[#90CAF9] text-white">
  <div class="container mx-auto px-4 text-center">
    <h2 class="text-3xl font-extrabold mb-4">Start Learning Today!</h2>
    <p class="text-lg mb-6">
      Unlock your potential with our expertly designed courses. 
      Join our community and enhance your skills in AI and blockchain technologies.
    </p>
    <a href="#courses" class="bg-[#0077b6] hover:bg-[#005f7f] text-white font-semibold py-3 px-6 rounded-lg transition duration-300">
      Explore Courses
    </a>
  </div>
</section> -->
<section id="courses" class="py-16 bg-gray-50" class:hidden={activeSection !== 'courses'}>
  <div class="container mx-auto px-4">

    <!-- Courses Section Header -->
    <div class="text-center mb-12">
      <h2 class="text-4xl font-extrabold text-[#0077b6] mb-4 transition duration-300 hover:underline">
        Available Courses
      </h2>
      <p class="text-gray-600 text-lg max-w-2xl mx-auto">
        Explore our curated courses designed to deepen your understanding of AI and blockchain technologies.
      </p>
    </div>

    <!-- Search and Filter -->
    <div class="flex flex-col md:flex-row justify-center items-center mb-8 space-y-4 md:space-y-0 md:space-x-4">
      <input 
        type="text" 
        placeholder="Search courses..." 
        bind:value={searchQuery}
        class="w-full md:w-1/3 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0077b6] transition duration-300 shadow-sm"
      />
      <select 
        bind:value={selectedTag} 
        class="w-full md:w-1/4 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0077b6] transition duration-300 shadow-sm"
      >
        <option value="All">All Tags</option>
        {#each tags as tag}
          <option value={tag}>{tag}</option>
        {/each}
      </select>
      <select 
        bind:value={selectedSort} 
        class="w-full md:w-1/4 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0077b6] transition duration-300 shadow-sm"
      >
        <option value="default">Sort By</option>
        <option value="rating">Rating</option>
        <option value="progress">Progress</option>
      </select>
    </div>

    <!-- Courses Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      {#if filteredCourses.length > 0}
        {#each filteredCourses as course}
          <div class="bg-white p-6 rounded-lg shadow-lg transition-transform duration-300 transform hover:scale-105 flex flex-col">
            <!-- Course Image -->
            <img src={course.image || 'default-image.jpg'} alt={course.title} class="w-full h-32 object-cover rounded-md mb-4 transition-transform duration-300 hover:scale-105" />

            <!-- Course Title -->
            <h3 class="text-xl font-semibold text-[#0077b6] mb-1">{course.title}</h3>

            <!-- Course Description -->
            <p class="text-gray-800 mb-3 flex-grow">{course.summary}</p>

            <!-- Start Learning Button -->
            <button
              on:click={() => startLearning(course.id)} 
              class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105">
              Start Learning
            </button>
          </div>
        {/each}
      {:else}
        <p class="text-center text-gray-600">No courses available. Try adjusting your search or filters.</p>
      {/if}
    </div>

    <div class="mt-4 text-center">
      <a href="/all-courses" class="text-[#0077b6] font-bold hover:underline" aria-label="View All Courses">
        View All Courses
      </a>
    </div>

  </div>
</section>

  <!-- Chatbots Section -->
 
    <section id="chatgpt-interface" class="py-16 bg-gray-100" class:hidden={activeSection !== 'chatbots'}>

    <div class="container mx-auto flex flex-col lg:flex-row max-w-6xl">
      <!-- Sidebar for Chat History -->
      <aside class="w-full lg:w-1/4 bg-white shadow-lg rounded-lg p-6 mb-8 lg:mb-0 lg:mr-8">
        <h3 class="text-xl font-bold text-gray-900 mb-6">Chat History</h3>
        <div class="overflow-y-auto max-h-[500px]">
          <ul class="space-y-4">
            {#each chatHistory as { date, topic }}
              <li>
                <button 
                  class="w-full text-left p-2 bg-gray-200 rounded-lg hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-[#E1AD01]"
                  on:click={() => loadChat(date, topic)}
                >
                  <div class="font-semibold text-gray-900">{topic}</div>
                  <div class="text-sm text-gray-600">{date}</div>
                </button>
              </li>
            {/each}
          </ul>
        </div>
      </aside>

      <!-- Main Chat Interface -->
      <div class="w-full lg:w-3/4 bg-white shadow-lg rounded-lg p-6 flex flex-col h-[500px]">
        <!-- Chat Window -->
        <div id="chat-window" class="flex-1 overflow-y-auto mb-4 border border-gray-300 rounded-lg p-4 bg-gray-50">
          <!-- Example Chat Messages -->
          <div class="mb-4">
            <div class="text-sm text-gray-600 mb-1">User:</div>
            <div class="bg-gray-200 p-2 rounded-lg">Hello, how can I use the chatbot?</div>
          </div>
          <div class="mb-4">
            <div class="text-sm text-gray-600 mb-1">Chatbot:</div>
            <div class="bg-[#E1AD01] text-white p-2 rounded-lg">You can ask me anything, and I'll provide the best possible answers!</div>
          </div>
        </div>

        <!-- Chat Input -->
        <div class="flex items-center border-t border-gray-300 pt-4">
          <input 
            type="text" 
            id="chat-input" 
            class="flex-1 p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E1AD01] transition duration-300"
            placeholder="Type your message here..."
          />
          <button 
            id="send-btn" 
            class="ml-4 bg-[#E1AD01] text-white py-2 px-4 rounded-lg hover:bg-[#D1A300] transition-colors duration-300"
          >
            Send
          </button>
        </div>
      </div>
    </div>
  </section>
 
  <section id="quizzes" class="py-16 bg-gradient-to-r from-[#e0f7fa] to-[#d7d8d8]">
  <div class="flex min-h-screen">
    <!-- Sidebar (Courses) -->
    <aside class="w-64 bg-gradient-to-r from-[#e0f7fa] to-[#d7d8d8] p-6">
      <h2 class="text-3xl font-bold text-[#0277bd] mb-6">Courses</h2>
      <ul class="space-y-4">
        {#each courses as course}
          <li>
            <div 
              on:click={() => fetchQuizzesForCourse(course.id)} 
              class="p-3 bg-white rounded-lg shadow-lg cursor-pointer hover:bg-[#0277bd] hover:text-white transition-all duration-300"
            >
              {course.title}
            </div>
          </li>
        {/each}
      </ul>
    </aside>

    <!-- Main Content (Quizzes) -->
    <main class="flex-grow p-10 bg-gray-100">
      <h2 class="text-5xl font-extrabold text-[#0277bd] mb-8">Quizzes</h2>
      <p class="text-gray-700 mb-12 text-lg max-w-2xl">
        Test your knowledge with our fun quizzes and earn tokens for your achievements.
      </p>

      <!-- Quizzes List -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
        {#if quizzes.length > 0}
          {#each quizzes as quiz}
            <div class="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-shadow duration-300 transform hover:scale-105 flex flex-col">
              <h3 class="text-2xl font-bold text-[#01579b] mb-4">{quiz.description}</h3>
              <ul class="mb-4">
                {#each quiz.options as option}
               
                <li class="text-lg text-gray-700">{`Option ${option.id}: ${option.text}`}</li>

                {/each}
              </ul>
              <div class="flex justify-center">
                <button
                  on:click={() => startQuiz(quiz.id)}
                  class="bg-[#01579b] text-white px-6 py-3 rounded-full shadow-lg hover:bg-[#0288d1] transition-all duration-300 transform hover:scale-105"
                >
                  Start Quiz
                </button>
              </div>
            </div>
          {/each}
        {:else}
          <p class="text-gray-500 text-lg">Select a course to view available quizzes.</p>
        {/if}
      </div>
      
    </main>
  </div>
</section>
  <!-- Rewards Section -->
  <section id="rewards" class="py-16 bg-gray-100" class:hidden={activeSection !== 'rewards'}>
    <div class="container mx-auto">
      <div class="text-center mb-12">
        <h2 class="text-5xl font-extrabold text-[#0f535c] mb-4">Rewards</h2>
        <p class="text-gray-700 text-lg max-w-2xl mx-auto">
          Earn tokens and redeem them for exciting rewards. Check out what you can get!
        </p>
      </div>

      <!-- Tabs Navigation -->
      <div class="flex justify-center mb-8 space-x-4">
        <button 
          on:click={() => handleTabChange('overview')} 
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === 'overview' 
              ? 'text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md' 
              : 'text-[#0077b6] hover:text-[#023e8a]'
          }`}
        >
          <i class="fas fa-info-circle mr-2"></i> Overview
        </button>
        <button 
          on:click={() => handleTabChange('tokens')} 
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === 'tokens' 
              ? 'text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md' 
              : 'text-[#0077b6] hover:text-[#023e8a]'
          }`}
        >
          <i class="fas fa-coins mr-2"></i> Your Tokens
        </button>
        <button 
          on:click={() => handleTabChange('recent')} 
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === 'recent' 
              ? 'text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md' 
              : 'text-[#0077b6] hover:text-[#023e8a]'
          }`}
        >
          <i class="fas fa-star mr-2"></i> Recent Rewards
        </button>
        <button 
          on:click={() => handleTabChange('redeem')} 
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === 'redeem' 
              ? 'text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md' 
              : 'text-[#0077b6] hover:text-[#023e8a]'
          }`}
        >
          <i class="fas fa-gift mr-2"></i> Redeem Rewards
        </button>
      </div>

      <!-- Content Area -->
      <div class="space-y-8">
        {#if activeTab === 'overview'}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">Overview</h3>
            <p class="text-gray-700 mb-6">
              Explore the rewards you can earn and redeem. Check your token balance and recent reward activities.
            </p>
            <!-- Add content or graphics here -->
          </section>
        {/if}

        {#if activeTab === 'tokens'}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">Your Tokens</h3>
            <p class="text-gray-700 mb-6">
              You currently have <span class="font-bold text-[#f59e0b]">{userTokens}</span> tokens.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div class="bg-[#f0f4f8] p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300">
                <h4 class="text-xl font-semibold text-[#0077b6] mb-2">{reward1}</h4>
                <p class="text-gray-600">Access to a free course of your choice.</p>
              </div>
              <div class="bg-[#f0f4f8] p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300">
                <h4 class="text-xl font-semibold text-[#0077b6] mb-2">{reward2}</h4>
                <p class="text-gray-600">Exclusive NFT Badge to showcase your achievements.</p>
              </div>
              <div class="bg-[#f0f4f8] p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300">
                <h4 class="text-xl font-semibold text-[#0077b6] mb-2">{reward3}</h4>
                <p class="text-gray-600">One-on-One Mentor Session with industry experts.</p>
              </div>
              <!-- Add more rewards as needed -->
            </div>
          </section>
        {/if}

        {#if activeTab === 'recent'}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">Recent Rewards</h3>
            <ul class="list-disc list-inside text-gray-700 space-y-3">
              <li>{recentToken1}</li>
              <li>{recentToken2}</li>
              <li>{recentToken3}</li>
            </ul>
          </section>
        {/if}

        {#if activeTab === 'redeem'}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">Redeem Rewards</h3>
            <p class="text-gray-700 mb-6">
              Here you can redeem your tokens for various rewards. Choose from our exciting options and use your tokens wisely!
            </p>

            <!-- Wallet Integration -->
            <div class="mb-8">
              <p class="text-gray-700 mb-4">Connect your wallet to proceed with the redemption:</p>
              <button 
                on:click={connectWallet} 
                class="bg-[#0077b6] text-white px-6 py-3 rounded-lg hover:bg-[#005f73] transition-colors duration-300 shadow-md hover:shadow-lg"
              >
                Connect Wallet
              </button>
            </div>

            <!-- Redemption Form -->
            <form on:submit={handleRedemption} class="space-y-6">
              <label class="block mb-2 text-gray-700" for="reward-select">Select Reward:</label>
              <select 
                id="reward-select" 
                class="block w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#023e8a] transition duration-300 shadow-lg hover:shadow-xl"
                bind:value={selectedReward}
              >
                <option value="" disabled>Select a reward</option>
                <option value="Free Course Access">{reward1}</option>
                <option value="Exclusive NFT Badge">{reward2}</option>
                <option value="One-on-One Mentor Session">{reward3}</option>
                <!-- Add more rewards as needed -->
              </select>

              <button 
                type="submit"
                class="w-full bg-[#0077b6] text-white px-6 py-3 rounded-lg hover:bg-[#005f73] transition-colors duration-300 shadow-md hover:shadow-lg"
              >
                Redeem Now
              </button>
            </form>
          </section>
        {/if}
      </div>
    </div>

    <!-- Modal for Course Details -->
    <Modal 
      showModal={showModal} 
      modalContent={modalContent} 
      onClose={closeModal} 
    />
  </section>

  <!-- Contact Section -->
  <section id="contact" class="py-16 bg-gray-50" class:hidden={activeSection !== 'contact'}>
    <div class="container mx-auto text-center">
      <h2 class="text-5xl font-extrabold text-[#0f535c] mb-8">Contact Us</h2>
      <p class="text-gray-700 mb-12 text-lg max-w-2xl mx-auto">
        Have questions or need assistance? Get in touch with us!
      </p>

      <div class="bg-white p-6 rounded-lg shadow-lg max-w-4xl mx-auto">
       <!--  <form action="#" method="POST" class="space-y-4">
          <div class="flex flex-col md:flex-row space-y-4 md:space-y-0 md:space-x-4">
            <input type="text" placeholder="Your Name" class="border border-gray-300 rounded-lg p-2 w-full md:w-1/2 focus:outline-none focus:ring-2 focus:ring-[#023e8a] transition duration-300 shadow-lg hover:shadow-xl" required />
            <input type="email" placeholder="Your Email" class="border border-gray-300 rounded-lg p-2 w-full md:w-1/2 focus:outline-none focus:ring-2 focus:ring-[#023e8a] transition duration-300 shadow-lg hover:shadow-xl" required />
          </div>
          <textarea placeholder="Your Message" class="border border-gray-300 rounded-lg p-2 w-full focus:outline-none focus:ring-2 focus:ring-[#023e8a] transition duration-300 shadow-lg hover:shadow-xl" rows="4" required></textarea>
          <button
            type="submit"
            class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105"
          >
            Send Message
          </button>
        </form> -->
      </div>
    </div>
  </section>

  <!-- Footer -->
  <footer class="bg-white text-[#0f535c] py-6 text-center">
    <div class="container mx-auto">
      <p>&copy; 2024 LLMVerse. All rights reserved.</p>
      <p class="mt-2">
        Follow us on 
        <a href="#" class="text-blue-300 hover:underline">Twitter</a>, 
        <a href="#" class="text-blue-300 hover:underline">Facebook</a>, 
        <a href="#" class="text-blue-300 hover:underline">Instagram</a>.
      </p>
    </div>
  </footer>
</main>

<style>
  /* Ensure responsiveness and proper spacing */
  main {
    padding-top: 5rem; /* Adjust if navbar height changes */
  }

  /* Modal Styles (if any additional styles are needed) */
</style>
