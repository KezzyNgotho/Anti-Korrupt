<script>
  import { onMount } from "svelte";
  import logo from "../../../public/image8.png";
  import hero from "../../../public/image9.png";
  import { createBackend } from "../helpers/utils";

  //   let activeSection = "courses"; // Default section
  //   let selectedSort = "default";
  //   let courses = [];
  //   let courseCanister;
  //   function handleNavClick(section) {
  //     activeSection = section;
  //     document.getElementById(section)?.scrollIntoView({ behavior: "smooth" });
  //   }
  //   let errorMessage = "";

  let resources = []; // Example resources array
  let questions = []; // Example questions array
  let principalID = "";
  let owners = []; // List of owners with permissions

  function addPermission() {
    if (principalID && !owners.includes(principalID)) {
      owners.push(principalID);
      principalID = ""; // Reset input field
    } else {
      alert("Please enter a valid Principal ID.");
    }
  }

  async function fetchCourses() {
    try {
      const backend = await createBackend();
      const response = await backend.listCourses();
      courses = response; // Set the fetched courses to filteredCourses
    } catch (error) {
      console.error("Error fetching courses:", error);
    }
  }

  // State Variables
  let activeSection = "home"; // Default section
  let selectedTab = "resources";

  // Function to toggle See All Courses
  function toggleSeeAll() {
    seeAll = !seeAll;
  }

  // Variables for toggling views and state
  let searchQuery = "";
  let selectedSort = "default";
  let showResources = false;
  let showQuestions = false;
  let selectedView = "resources"; // 'resources' or 'questions'

  let newResource = {
    title: "",
    type: "",
    file: null,
  };

  function handleViewCourse() {
    showResources = true;
    showQuestions = false;
  }

  function switchView(view) {
    selectedView = view;
  }
  function switchTab(tab) {
    selectedTab = tab;
  }

  function updateCourse(course) {
    // Logic to update an existing course
    console.log("Updating course: ", course);
  }

  function handleResourceUpload(event) {
    newResource.file = event.target.files[0];
  }

  function addNewResource() {
    if (newResource.title && newResource.type && newResource.file) {
      resources.push({
        title: newResource.title,
        type: newResource.type,
        url: URL.createObjectURL(newResource.file),
      });
      newResource = { title: "", type: "", file: null }; // Reset the form
    } else {
      alert("Please complete all fields.");
    }
  }

  function generateRandomQuestion() {
    const randomQuestion = {
      question: "What is AI's role in the digital age?",
      options: [
        { text: "To replace human jobs", isCorrect: false },
        { text: "To assist in decision-making", isCorrect: true },
        { text: "To manage databases", isCorrect: false },
        { text: "To generate random numbers", isCorrect: false },
      ],
    };
    questions.push(randomQuestion);
  }

  const CourseStatus = {
    InFix: "InFix",
    InReview: "InReview",
    Rejected: "Rejected",
    Approved: "Approved",
  };

  function getEnum(value, enumType) {
    return enumType[value] || "Unknown";
  }

  // Determine course status color
  let statusColor = "";
  const status = "Approved";

  // Recent Tokens Data
  let recentToken1 = "Completed AI Basics Quiz: +10 tokens";
  let recentToken2 = "Completed Blockchain 101 Quiz: +12 tokens";
  let recentToken3 = "Completed DeFi & Fintech Quiz: +8 tokens";

  // Rewards Data
  let reward1 = "Free Course Access";
  let reward2 = "Exclusive NFT Badge";
  let reward3 = "One-on-One Mentor Session";

  // Chat History Data
  let chatHistory = [
    { date: "2024-09-01", topic: "Customer Support" },
    { date: "2024-08-15", topic: "Learning Assistance" },
  ];

  let newCourse = {
    title: "",
    description: "",
  };

  // Functions
  // Call initializeBackend and fetchCourses on mount to populate courses data
  onMount(async () => {
    await fetchCourses();
  });

  let leaderboard = [
    { name: "Alice", avatar: "https://via.placeholder.com/40", score: 120 },
    { name: "Bob", avatar: "https://via.placeholder.com/40", score: 110 },
    { name: "Charlie", avatar: "https://via.placeholder.com/40", score: 100 },
    { name: "Dave", avatar: "https://via.placeholder.com/40", score: 90 },
    { name: "Eve", avatar: "https://via.placeholder.com/40", score: 80 },
  ];

  // Sample data for top users
  let topUsers = [
    {
      rank: 1,
      name: "Alice",
      avatar: "https://via.placeholder.com/40",
      score: 120,
    },
    {
      rank: 2,
      name: "Bob",
      avatar: "https://via.placeholder.com/40",
      score: 110,
    },
    {
      rank: 3,
      name: "Charlie",
      avatar: "https://via.placeholder.com/40",
      score: 100,
    },
  ];

  // User's progress percentage (for progress tracker)
  let userProgressPercentage = 75; // Example value

  // Variable for selected timeframe
  let timeFrame = "weekly";

  // Function to refresh the leaderboard based on selected timeframe
  function refreshLeaderboard() {
    // Logic to update the leaderboard based on the selected timeframe
    // This is where you would normally fetch new data based on the timeFrame
    console.log(`Leaderboard refreshed for ${timeFrame} timeframe.`);
  }

  // Example of how to handle the change in timeframe
  $: {
    refreshLeaderboard(); // Call refresh whenever the timeFrame changes
  }

  let seeAll = false;
  let activeTab = "overview";
  let selectedReward = "";
  let userTokens = 50;
  let quizTimer = 60;

  let quizzes = [
    {
      title: "AI Basics Quiz",
      description: "Test your knowledge of AI fundamentals.",
      questions: 10,
    },
    {
      title: "Blockchain 101 Quiz",
      description: "How well do you know blockchain technology?",
      questions: 12,
    },
    {
      title: "DeFi & Fintech Quiz",
      description:
        "Assess your understanding of decentralized finance and fintech.",
      questions: 8,
    },
  ];

  let userProgress = {
    "introduction-to-ai-and-blockchain": 0,
    "advanced-ai-techniques": 70,
    "blockchain-development-essentials": 45,
  };

  // Handle Tab Change in Rewards Section
  const handleTabChange = (tab) => {
    activeTab = tab;
  };

  // Handle Navigation Click
  function handleNavClick(section) {
    activeSection = section;
    const element = document.getElementById(section);
    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }

  // Start Learning a Course
  function startLearning(courseId) {
    activeSection = "chatgpt-interface";
    userTokens += 10; // Reward for starting the course
    const element = document.getElementById("chatgpt-interface");
    if (element) {
      element.scrollIntoView({ behavior: "smooth" });
    }
  }

  let timeTaken = 45; // Example time taken to complete a quiz

  // Start a Quiz
  function startQuiz(quiz) {
    let startTime = Date.now();
    setTimeout(() => {
      let endTime = Date.now();
      if (timeTaken <= quizTimer) {
        userTokens += 10;
      }
      console.log(
        `Quiz completed in ${timeTaken} seconds. Tokens earned: ${userTokens}`,
      );
      // Optionally, update recent tokens or show a success message
    }, quizTimer * 1000);
  }

  // Handle Redemption Form Submission
  const handleRedemption = (event) => {
    event.preventDefault();
    if (selectedReward) {
      console.log(`Redeeming ${selectedReward}`);
      userTokens -= getRewardCost(selectedReward);
      recentToken1 = `Redeemed ${selectedReward}: -${getRewardCost(selectedReward)} tokens`;
    } else {
      console.error("Please select a reward.");
    }
  };

  // Get Reward Cost
  function getRewardCost(reward) {
    const rewardCosts = {
      "Free Course Access": 20,
      "Exclusive NFT Badge": 50,
      "One-on-One Mentor Session": 100,
    };
    return rewardCosts[reward] || 0;
  }

  // Connect Wallet
  const connectWallet = () => {
    console.log("Connecting wallet...");
  };

  // Load Chat
  function loadChat(date, topic) {
    console.log(`Loading chat for ${topic} on ${date}`);
  }

  function addNewCourse() {
    if (newCourse.title && newCourse.description) {
      courses.push({ ...newCourse });
      newCourse = { title: "", description: "" }; // Reset form
    } else {
      alert("Please complete both title and description.");
    }
  }

  let courses = [];

  // On Mount
  onMount(() => {
    handleNavClick("home"); // Set the default section on page load
  });
</script>

<!-- Navbar -->
<header
  class="bg-gradient-to-r from-[#0f535c] to-[#38a0ac] text-white py-4 px-6 flex flex-col md:flex-row items-center justify-between shadow-lg fixed top-0 w-full z-50"
>
  <div class="flex items-center space-x-4">
    <a href="/" class="flex items-center space-x-2">
      <img
        src={logo}
        alt="LLM Logo"
        class="w-10 h-10 sm:w-14 sm:h-14 rounded-full border-4 border-blue-200 transition-transform transform hover:scale-110 duration-300"
      />
      <h1 class="text-xl sm:text-2xl md:text-3xl font-bold">LLMVerse</h1>
    </a>
  </div>

  <!-- Center Links (Desktop) -->
  <nav class="hidden md:flex flex-grow justify-center space-x-6 mt-4 md:mt-0">
    {#each ["Home", "Courses", "Chatbots", "Quizzes", "Rewards", "Contact", "admin"] as link}
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
      on:click={() => handleNavClick("courses")}
      class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105"
    >
      Get Started 🚀
    </button>
    <button
      on:click={() => handleNavClick("rewards")}
      class="bg-transparent border border-blue-200 text-white px-4 py-2 rounded-full shadow-md hover:bg-blue-300 hover:text-[#023e8a] transition-all duration-300 transform hover:scale-105"
    >
      Rewards 🤝
    </button>
  </div>
</header>

<!-- Main Content -->
<main class="">
  <!-- Add padding-top to offset the fixed navbar -->

  <section
    id="home"
    class:hidden={activeSection !== "home"}
    class="hero min-h-screen flex items-center justify-center bg-[#0f535c] text-white"
  >
    <div
      class="container mx-auto flex flex-col md:flex-row items-center justify-between p-8"
    >
      <!-- Left Side: Text Content -->
      <div class="text-content md:w-1/2 text-center md:text-left">
        <h1 class="text-4xl md:text-5xl font-bold mb-4 leading-tight">
          Welcome to <span class="text-[#E1AD01]">Anti-Corrupt AI </span>Expand
          your knowledge on corruption using
        </h1>
        <p class="text-lg md:text-xl mb-6">
          Leveraging the power of blockchain and AI to enhance learning and
          create an overall corruption free environment all over the world.
        </p>
        <!-- Styled Buttons -->
        <div class="flex justify-center md:justify-start space-x-4">
          <button
            class="bg-[#E1AD01] text-white px-11 py-2 text-lg font-semibold shadow-lg hover:bg-white hover:text-[#0077b6] transition-all duration-300 ease-in-out transform hover:scale-105"
          >
            Sign Up
          </button>
          <button
            class="bg-[#00C4CC] text-white px-11 py-2 text-lg font-semibold shadow-lg hover:bg-white hover:text-[#0077b6] transition-all duration-300 ease-in-out transform hover:scale-105"
          >
            Go to learning
          </button>
        </div>
      </div>

      <!-- Right Side: Image or Graphic -->
      <div class="image-content md:w-1/2 mt-8 md:mt-0">
        <img
          src={logo}
          alt="LLM Hero Graphic"
          class="w-150 h-auto rounded-lg"
        />
        <img
          src={hero}
          alt="LLM Hero Graphic"
          class="w-150 h-auto rounded-lg"
        />
      </div>
    </div>
  </section>

  <!-- Courses Section -->

  <section
    id="courses"
    class="py-16 bg-gray-50 min-h-screen"
    class:hidden={activeSection !== "courses"}
  >
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0f535c] mb-8">
        Available Courses
      </h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">
        Explore our curated courses designed to deepen your understanding of AI
        and blockchain technologies.
      </p>

      <section
        id="courses"
        class="py-16 bg-gray-50"
        class:hidden={activeSection !== "courses"}
      >
        <div class="container mx-auto px-4">
          <!-- Courses Section Header -->
          <div class="text-center mb-12">
            <h2
              class="text-4xl font-extrabold text-[#0077b6] mb-4 transition duration-300 hover:underline"
            >
              Available Courses
            </h2>
            <p class="text-gray-600 text-lg max-w-2xl mx-auto">
              Explore our curated courses designed to deepen your understanding
              of AI and blockchain technologies.
            </p>
          </div>

          <!-- Search and Filter -->
          <div
            class="flex flex-col md:flex-row justify-center items-center mb-8 space-y-4 md:space-y-0 md:space-x-4"
          >
            <input
              type="text"
              placeholder="Search courses..."
              bind:value={searchQuery}
              class="w-full md:w-1/3 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0077b6] transition duration-300 shadow-sm"
            />
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
            {#each courses as { id, title, summary }}
              <div
                class="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105"
              >
                <h3 class="text-xl font-semibold text-[#023e8a] mb-4">
                  {title}
                </h3>
                <p class="text-gray-800 mb-4">{summary}</p>
                <div class="h-2 bg-gray-200 rounded-full mb-4">
                  <div
                    class="h-full bg-[#023e8a] rounded-full"
                    style="width: {userProgress[id] || 0}%"
                  ></div>
                </div>
                <div class="flex justify-center space-x-4">
                  <button
                    on:click={() => startLearning(id)}
                    class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105"
                  >
                    Start Learning
                  </button>
                </div>
              </div>
            {/each}
            {#if courses.length === 0}
              <p class="text-center text-gray-600">
                No courses available. Try adjusting your search or filters.
              </p>
            {/if}
          </div>

          <div class="mt-4 text-center">
            <a
              href="/all-courses"
              class="text-[#0077b6] font-bold hover:underline"
              aria-label="View All Courses"
            >
              View All Courses
            </a>
          </div>
        </div>
      </section>

      <!-- Chatbots Section -->

      <section
        id="chatgpt-interface"
        class="py-16 bg-gray-100"
        class:hidden={activeSection !== "chatbots"}
      >
        <div class="container mx-auto flex flex-col lg:flex-row max-w-6xl">
          <!-- Sidebar for Chat History -->
          <aside
            class="w-full lg:w-1/4 bg-white shadow-lg rounded-lg p-6 mb-8 lg:mb-0 lg:mr-8"
          >
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
          <div
            class="w-full lg:w-3/4 bg-white shadow-lg rounded-lg p-6 flex flex-col h-[500px]"
          >
            <!-- Chat Window -->
            <div
              id="chat-window"
              class="flex-1 overflow-y-auto mb-4 border border-gray-300 rounded-lg p-4 bg-gray-50"
            >
              <!-- Example Chat Messages -->
              <div class="mb-4">
                <div class="text-sm text-gray-600 mb-1">User:</div>
                <div class="bg-gray-200 p-2 rounded-lg">
                  Hello, how can I use the chatbot?
                </div>
              </div>
              <div class="mb-4">
                <div class="text-sm text-gray-600 mb-1">Chatbot:</div>
                <div class="bg-[#E1AD01] text-white p-2 rounded-lg">
                  You can ask me anything, and I'll provide the best possible
                  answers!
                </div>
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

      <!-- Quizzes Section -->
      <section
        id="quizzes"
        class="py-16 bg-gradient-to-r from-[#e0f7fa] to-[#d7d8d8]"
        class:hidden={activeSection !== "quizzes"}
      >
        <div class="container mx-auto text-center">
          <h2 class="text-5xl font-extrabold text-[#0277bd] mb-8">Quizzes</h2>
          <!-- <p class="text-gray-700 mb-12 text-lg max-w-2xl mx-auto">
        Test your knowledge with our fun quizzes and earn tokens for your achievements.
      </p>
 -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
            {#each quizzes as quiz}
              <div
                class="bg-white p-6 rounded-xl shadow-lg hover:shadow-2xl transition-shadow duration-300 transform hover:scale-105 flex flex-col"
              >
                <h3 class="text-2xl font-bold text-[#01579b] mb-4">
                  {quiz.title}
                </h3>
                <p class="text-gray-700 mb-4 flex-grow">{quiz.description}</p>
                <div class="flex justify-center">
                  <button
                    class="bg-transparent border border-[#023e8a] text-[#023e8a] px-4 py-2 rounded-full shadow-md hover:bg-[#023e8a] hover:text-white transition-all duration-300 transform hover:scale-105"
                  >
                    View Details
                  </button>
                </div>
              </div>
            {/each}
          </div>
        </div>
      </section>

      <!-- "See All" button -->
      <div class="col-span-full text-center mt-6">
        <button on:click={toggleSeeAll} class="text-[#023e8a] hover:underline">
          {seeAll ? "Show Less" : "See All"}
        </button>
      </div>
    </div>

    {#if seeAll}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-12">
        {#each [{ id: "defi-and-fintech", title: "DeFi and Fintech", description: "Explore the decentralized finance (DeFi) space and the future of fintech with blockchain." }, { id: "ai-ethics-and-governance", title: "AI Ethics and Governance", description: "Understand the ethical implications of AI and how governance frameworks are shaping its development." }] as { id, title, description }}
          <div
            class="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105"
          >
            <h3 class="text-xl font-semibold text-[#023e8a] mb-4">{title}</h3>
            <p class="text-gray-800 mb-4">{description}</p>
            <div class="h-2 bg-gray-200 rounded-full mb-4">
              <div
                class="h-full bg-[#023e8a] rounded-full"
                style="width: {userProgress[id] || 0}%"
              ></div>
            </div>
            <div class="flex justify-center space-x-4">
              <button
                on:click={() => startLearning(id)}
                class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105"
              >
                Start Learning
              </button>
              <button
                class="bg-transparent border border-[#023e8a] text-[#023e8a] px-4 py-2 rounded-full shadow-md hover:bg-[#023e8a] hover:text-white transition-all duration-300 transform hover:scale-105"
              >
                View Details
              </button>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </section>

  <!-- Chatbots Section -->
  <section
    id="chatgpt-interface min-h-screen"
    class="py-16 bg-gray-100"
    class:hidden={activeSection !== "chatbots"}
  >
    <div class="container mx-auto flex flex-col lg:flex-row max-w-6xl">
      <!-- Sidebar for Chat History -->
      <aside
        class="w-full lg:w-1/4 bg-white shadow-lg rounded-lg p-6 mb-8 lg:mb-0 lg:mr-8"
      >
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
      <div
        class="w-full lg:w-3/4 bg-white shadow-lg rounded-lg p-6 flex flex-col h-[500px]"
      >
        <!-- Chat Window -->
        <div
          id="chat-window"
          class="flex-1 overflow-y-auto mb-4 border border-gray-300 rounded-lg p-4 bg-gray-50"
        >
          <!-- Example Chat Messages -->
          <div class="mb-4">
            <div class="text-sm text-gray-600 mb-1">User:</div>
            <div class="bg-gray-200 p-2 rounded-lg">
              Hello, how can I use the chatbot?
            </div>
          </div>
          <div class="mb-4">
            <div class="text-sm text-gray-600 mb-1">Chatbot:</div>
            <div class="bg-[#E1AD01] text-white p-2 rounded-lg">
              You can ask me anything, and I'll provide the best possible
              answers!
            </div>
          </div>
        </div>

        <!-- Chat Input -->
        <div class="flex items-center border-t border-gray-300 pt-4">
          <input
            type="text"
            id="chat-input"
            class="flex-1 p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E1AD01]"
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

  <!-- Quizzes Section -->
  <section
    id="quizzes"
    class="py-16 bg-gradient-to-r from-[#e0f7fa] to-[#d7d8d8] min-h-screen"
    class:hidden={activeSection !== "quizzes"}
  >
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0277bd] mb-8">Quizzes</h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">
        Test your knowledge with our fun quizzes and earn tokens for your
        achievements.
      </p>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {#each quizzes as quiz}
          <div
            class="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-300 transform hover:scale-105"
          >
            <h3 class="text-xl font-bold text-[#01579b] mb-4">{quiz.title}</h3>
            <p class="text-gray-700 mb-4">{quiz.description}</p>
            <div class="flex justify-center">
              <button
                on:click={() => startQuiz(quiz)}
                class="bg-[#01579b] text-white px-6 py-3 rounded-full shadow-lg hover:bg-[#0288d1] transition-all duration-300 transform hover:scale-105"
              >
                Start Quiz
              </button>
            </div>
          </div>
        {/each}
      </div>
    </div>
  </section>

  <!-- Rewards Section -->
  <section
    id="rewards"
    class="py-16 bg-gray-100 min-h-screen"
    class:hidden={activeSection !== "rewards"}
  >
    <div class="container mx-auto">
      <div class="text-center mb-12">
        <h2 class="text-4xl font-extrabold text-[#0f535c] mb-4">Rewards</h2>
        <p class="text-gray-600 text-lg max-w-2xl mx-auto">
          Earn tokens and redeem them for exciting rewards. Check out what you
          can get!
        </p>
      </div>

      <!-- Tabs Navigation -->
      <div class="flex justify-center mb-8 space-x-4">
        <button
          on:click={() => handleTabChange("overview")}
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === "overview"
              ? "text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md"
              : "text-[#0077b6] hover:text-[#023e8a]"
          }`}
        >
          <i class="fas fa-info-circle mr-2"></i> Overview
        </button>
        <button
          on:click={() => handleTabChange("tokens")}
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === "tokens"
              ? "text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md"
              : "text-[#0077b6] hover:text-[#023e8a]"
          }`}
        >
          <i class="fas fa-coins mr-2"></i> Your Tokens
        </button>
        <button
          on:click={() => handleTabChange("recent")}
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === "recent"
              ? "text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md"
              : "text-[#0077b6] hover:text-[#023e8a]"
          }`}
        >
          <i class="fas fa-star mr-2"></i> Recent Rewards
        </button>
        <button
          on:click={() => handleTabChange("redeem")}
          class={`px-4 py-2 text-lg font-semibold transition-colors duration-300 ${
            activeTab === "redeem"
              ? "text-[#023e8a] bg-[#e0f7fa] rounded-md shadow-md"
              : "text-[#0077b6] hover:text-[#023e8a]"
          }`}
        >
          <i class="fas fa-gift mr-2"></i> Redeem Rewards
        </button>
      </div>

      <!-- Content Area -->
      <div class="space-y-8">
        {#if activeTab === "overview"}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">
              Overview
            </h3>
            <p class="text-gray-700 mb-6">
              Explore the rewards you can earn and redeem. Check your token
              balance and recent reward activities.
            </p>
            <!-- Add content or graphics here -->
          </section>
        {/if}

        {#if activeTab === "tokens"}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">
              Your Tokens
            </h3>
            <p class="text-gray-700 mb-6">
              You currently have <span class="font-bold text-[#f59e0b]"
                >{userTokens}</span
              > tokens.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div
                class="bg-[#f0f4f8] p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300"
              >
                <h4 class="text-xl font-semibold text-[#0077b6] mb-2">
                  {reward1}
                </h4>
                <p class="text-gray-600">
                  Access to a free course of your choice.
                </p>
              </div>
              <div
                class="bg-[#f0f4f8] p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300"
              >
                <h4 class="text-xl font-semibold text-[#0077b6] mb-2">
                  {reward2}
                </h4>
                <p class="text-gray-600">
                  Exclusive NFT Badge to showcase your achievements.
                </p>
              </div>
              <div
                class="bg-[#f0f4f8] p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300"
              >
                <h4 class="text-xl font-semibold text-[#0077b6] mb-2">
                  {reward3}
                </h4>
                <p class="text-gray-600">
                  One-on-One Mentor Session with industry experts.
                </p>
              </div>
              <!-- Add more rewards as needed -->
            </div>
          </section>
        {/if}

        {#if activeTab === "recent"}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">
              Recent Rewards
            </h3>
            <ul class="list-disc list-inside text-gray-700 space-y-3">
              <li>{recentToken1}</li>
              <li>{recentToken2}</li>
              <li>{recentToken3}</li>
            </ul>
          </section>
        {/if}

        {#if activeTab === "redeem"}
          <section class="bg-white p-8 rounded-lg shadow-xl">
            <h3 class="text-3xl font-extrabold text-[#023e8a] mb-4">
              Redeem Rewards
            </h3>
            <p class="text-gray-700 mb-6">
              Here you can redeem your tokens for various rewards. Choose from
              our exciting options and use your tokens wisely!
            </p>

            <!-- Wallet Integration -->
            <div class="mb-8">
              <p class="text-gray-700 mb-4">
                Connect your wallet to proceed with the redemption:
              </p>
              <button
                on:click={connectWallet}
                class="bg-[#0077b6] text-white px-6 py-3 rounded-lg hover:bg-[#005f73] transition-colors duration-300"
              >
                Connect Wallet
              </button>
            </div>

            <!-- Redemption Form -->
            <form on:submit={handleRedemption} class="space-y-6">
              <label class="block mb-2 text-gray-700" for="reward-select"
                >Select Reward:</label
              >
              <select
                id="reward-select"
                class="block w-full p-3 border border-gray-300 rounded-lg"
                bind:value={selectedReward}
              >
                <option value="" disabled>Select a reward</option>
                <option value="course">{reward1}</option>
                <option value="nft">{reward2}</option>
                <option value="mentor">{reward3}</option>
                <!-- Add more rewards as needed -->
              </select>

              <button
                type="submit"
                class="bg-[#0077b6] text-white px-6 py-3 rounded-lg hover:bg-[#005f73] transition-colors duration-300"
              >
                Redeem Now
              </button>
            </form>
          </section>
        {/if}
      </div>
    </div>
  </section>

  <!-- Contact Section -->
  <section
    id="contact"
    class="py-16 bg-gray-50 min-h-screen"
    class:hidden={activeSection !== "contact"}
  >
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0f535c] mb-8">Contact Us</h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">
        Have questions or need assistance? Get in touch with us!
      </p>

      <div class="bg-white p-6 rounded-lg shadow-lg max-w-4xl mx-auto">
        <form action="#" method="POST" class="space-y-4">
          <div
            class="flex flex-col md:flex-row space-y-4 md:space-y-0 md:space-x-4"
          >
            <input
              type="text"
              placeholder="Your Name"
              class="border border-gray-300 rounded-lg p-2 w-full md:w-1/2"
              required
            />
            <input
              type="email"
              placeholder="Your Email"
              class="border border-gray-300 rounded-lg p-2 w-full md:w-1/2"
              required
            />
          </div>
          <textarea
            placeholder="Your Message"
            class="border border-gray-300 rounded-lg p-2 w-full"
            rows="4"
            required
          ></textarea>
          <button
            type="submit"
            class="bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105"
          >
            Send Message
          </button>
        </form>
      </div>
    </div>
  </section>

  <!-- Admin section -->
  <section
    id="admin"
    class="py-16 bg-[#0f535c] text-white"
    class:hidden={activeSection !== "admin"}
  >
    <div class="container mx-auto space-y-8">
      <!-- Tab Navigation -->
      <div class="flex justify-center space-x-8 mb-6">
        <button
          class="text-xl font-bold px-4 py-2 rounded-lg border transition-all duration-300 {selectedTab ===
          'courses'
            ? 'bg-[#E1AD01] text-white'
            : 'border-gray-300'}"
          on:click={() => switchTab("courses")}
        >
          Courses
        </button>
        <button
          class="text-xl font-bold px-4 py-2 rounded-lg border transition-all duration-300 {selectedTab ===
          'permissions'
            ? 'bg-[#E1AD01] text-white'
            : 'border-gray-300'}"
          on:click={() => switchTab("permissions")}
        >
          Permissions
        </button>
      </div>

      <!-- Courses Section -->
      {#if selectedTab === "courses"}
        <div class="space-y-8">
          <!-- Add New Course Section -->
          <div
            class="max-w-xl mx-auto bg-white text-gray-900 p-6 rounded-lg shadow-lg mt-8"
          >
            <h3 class="text-2xl font-bold mb-4 text-[#0f535c]">
              Add New Course
            </h3>
            <form on:submit|preventDefault={addNewCourse} class="space-y-4">
              <input
                type="text"
                placeholder="Course Title"
                class="block w-full p-2 border rounded-lg"
                bind:value={newCourse.title}
                required
              />
              <textarea
                placeholder="Course Description"
                class="block w-full p-2 border rounded-lg"
                bind:value={newCourse.description}
                required
              ></textarea>
              <button
                type="submit"
                class="bg-[#0f535c] text-white px-4 py-2 rounded-lg hover:bg-[#E1AD01] transition-all duration-300"
              >
                + Add Course
              </button>
            </form>
          </div>

          <!-- Course List -->
          {#each courses as course}
            <div
              class="max-w-xs min-w-[320px] bg-white text-[#0f535c] shadow-2xl rounded-md overflow-hidden mx-auto"
            >
              <div class="p-6">
                <div class="text-center mb-5">
                  <h2 class="text-2xl font-bold">{course.title}</h2>
                  <p class="mt-2 text-gray-700">{course.description}</p>
                  <span class="px-3 py-1 text-white bg-[#E1AD01] rounded"
                    >Approved</span
                  >
                </div>

                <div class="flex justify-around mb-5">
                  <div class="text-center">
                    <p class="font-semibold text-lg">50</p>
                    <p class="text-gray-500">Enrolled</p>
                  </div>
                  <div class="text-center">
                    <p class="font-semibold text-lg">3</p>
                    <p class="text-gray-500">Reports</p>
                  </div>
                </div>

                <div class="flex justify-center space-x-4">
                  <button
                    class="bg-[#0f535c] text-white py-2 px-4 rounded-md hover:bg-[#E1AD01] transition-all duration-200"
                    on:click={handleViewCourse}
                  >
                    View Course
                  </button>
                  <button
                    class="bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600 transition-all duration-200"
                    on:click={() => updateCourse(course)}
                  >
                    Update Course
                  </button>
                </div>
              </div>
            </div>
          {/each}

          {#if showResources}
            <!-- Toggle Buttons to Switch Between Resources and Questions -->
            <div class="flex justify-center space-x-8 mb-6">
              <button
                class="text-xl font-bold px-4 py-2 rounded-lg border transition-all duration-300 {selectedView ===
                'resources'
                  ? 'bg-[#E1AD01] text-white'
                  : 'border-gray-300'}"
                on:click={() => switchView("resources")}
              >
                Resources
              </button>
              <button
                class="text-xl font-bold px-4 py-2 rounded-lg border transition-all duration-300 {selectedView ===
                'questions'
                  ? 'bg-[#E1AD01] text-white'
                  : 'border-gray-300'}"
                on:click={() => switchView("questions")}
              >
                Questions
              </button>
            </div>

            <!-- Resource Section -->
            {#if selectedView === "resources"}
              <div class="space-y-8">
                {#each resources as resource}
                  <div
                    class="max-w-xs min-w-[320px] bg-gray-900 text-white shadow-2xl rounded-md p-6 text-center mx-auto"
                  >
                    <h2 class="text-2xl font-bold">{resource.title}</h2>
                    <p class="text-gray-400 mt-4">
                      Resource Type: {resource.type}
                    </p>

                    <div class="mt-6">
                      <span class="px-3 py-1 bg-gray-700 rounded"
                        >{resource.type}</span
                      >
                    </div>

                    <div class="mt-8">
                      <a href={resource.url} target="_blank">
                        <div class="flex space-x-4">
                          <button
                            class="bg-[#0f535c] hover:bg-[#E1AD01] text-white font-semibold py-2 px-4 rounded transition-all duration-200"
                          >
                            View Resource
                          </button>
                          <button
                            class="bg-[#0f535c] hover:bg-[#E1AD01] text-white font-semibold py-2 px-4 rounded transition-all duration-200"
                          >
                            Delete Resource
                          </button>
                        </div>
                      </a>
                    </div>
                  </div>
                {/each}

                <!-- Add New Resource Form -->
                <div
                  class="max-w-xl mx-auto bg-white text-gray-900 p-6 rounded-lg shadow-lg mt-8"
                >
                  <h3 class="text-2xl font-bold mb-4 text-[#0f535c]">
                    Add New Resource
                  </h3>
                  <form
                    on:submit|preventDefault={addNewResource}
                    class="space-y-4"
                  >
                    <input
                      type="text"
                      placeholder="Resource Title"
                      class="block w-full p-2 border rounded-lg"
                      bind:value={newResource.title}
                      required
                    />
                    <input
                      type="text"
                      placeholder="Resource Type (e.g., Book, Video)"
                      class="block w-full p-2 border rounded-lg"
                      bind:value={newResource.type}
                      required
                    />
                    <input
                      type="file"
                      accept=".pdf,.doc,.docx,.mp4"
                      class="block w-full p-2 border rounded-lg"
                      on:change={handleResourceUpload}
                      required
                    />
                    <button
                      type="submit"
                      class="bg-[#0f535c] text-white px-4 py-2 rounded-lg hover:bg-[#E1AD01] transition-all duration-300"
                    >
                      Add Resource
                    </button>
                  </form>
                </div>
              </div>
            {/if}

            <!-- Questions Section -->
            {#if selectedView === "questions"}
              <div
                class="bg-white text-[#0f535c] p-6 rounded-md shadow-lg mx-auto max-w-xl"
              >
                <h2 class="text-2xl font-bold text-center mb-6">Questions</h2>

                {#each questions as question, i}
                  <div class="mb-8">
                    <p class="text-lg font-semibold">
                      {i + 1}. {question.question}
                    </p>
                    <ul class="mt-2">
                      {#each question.options as option}
                        <li
                          class="mt-2 px-4 py-2 rounded-lg {option.isCorrect
                            ? 'bg-green-100 border-l-4 border-green-500'
                            : 'bg-gray-100'}"
                        >
                          {option.text}
                        </li>
                      {/each}
                    </ul>
                  </div>
                {/each}

                <!-- Generate New Question Button -->
                <div class="mt-8 text-center">
                  <button
                    class="bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg hover:bg-green-600 transition-all duration-300"
                    on:click={generateRandomQuestion}
                  >
                    + Generate Question
                  </button>
                </div>
              </div>
            {/if}
          {/if}
        </div>
      {/if}

      <!-- Permissions Section (Already existing) -->
      {#if selectedTab === "permissions"}
        <div
          class="max-w-xl mx-auto bg-white text-gray-900 p-6 rounded-lg shadow-lg mt-8 min-h-screen"
        >
          <h3 class="text-2xl font-bold mb-4 text-[#0f535c]">
            Manage Permissions
          </h3>
          <form on:submit|preventDefault={addPermission} class="space-y-4">
            <input
              type="text"
              placeholder="Enter Principal ID"
              class="block w-full p-2 border rounded-lg"
              bind:value={principalID}
              required
            />
            <button
              type="submit"
              class="bg-[#0f535c] text-white px-4 py-2 rounded-lg hover:bg-[#E1AD01] transition-all duration-300"
            >
              Add Permission
            </button>
          </form>

          <!-- Display Owners -->
          <h4 class="text-xl font-bold mt-6">Owners with Permissions:</h4>
          <ul class="list-disc list-inside text-gray-700 mt-4">
            {#each owners as owner}
              <li>{owner}</li>
            {/each}
          </ul>
        </div>
      {/if}
    </div>
  </section>

  <!-- Footer -->
  <footer
    class="bg-gradient-to-r from-[#0f535c] to-[#38a0ac] text-white py-6 text-center"
  >
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
