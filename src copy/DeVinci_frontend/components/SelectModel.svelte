<script>
  import { onMount } from 'svelte';
  import logo from '../../../public/image8.png';




  let activeSection = 'courses';
  let seeAll = false; // New state to toggle 'See All' visibility

  let userProgress = {
    'introduction-to-ai-and-blockchain': 0,
    'advanced-ai-techniques': 70,
    'blockchain-development-essentials': 45,
    'defi-and-fintech': 30,
    'ai-ethics-and-governance': 10,
  };

  // Function to toggle 'See All'
  function toggleSeeAll() {
    seeAll = !seeAll;
  }

  onMount(() => {
    handleNavClick('courses'); // Set the default section to be displayed on load
  });

  function handleNavClick(section) {
    activeSection = section;
    document.getElementById(section)?.scrollIntoView({ behavior: 'smooth' });
  }

  function startLearning(courseId) {
    activeSection = 'chatbots';
    document.getElementById('chatgpt-interface')?.scrollIntoView({ behavior: 'smooth' });
  }

 // let activeSection = 'courses';
  /* let userProgress = {
    'introduction-to-ai-and-blockchain': 0,
    'advanced-ai-techniques': 70,
    'blockchain-development-essentials': 45,
  }; */

  /* function handleNavClick(section) {
    activeSection = section;
    document.getElementById(section)?.scrollIntoView({ behavior: 'smooth' });
  } */

/*   function startLearning(courseId) {
    handleNavClick('chatgpt-interface');
  } */

  onMount(() => {
    handleNavClick('courses'); // Set the default section to be displayed on load
  });

  function loadChat(date, topic) {
    // Function to load chat history based on the selected topic
    console.log("Loading chat for", date, topic);
    // You can implement logic to display the selected chat history in the chat window
  }


//  let activeSection = 'courses'; // Default section

 /*  function handleNavClick(section) {
    activeSection = section;
    document.getElementById(section)?.scrollIntoView({ behavior: 'smooth' });
  }
 */
  /* function startLearning(courseId) {
    // Redirect to the Chatbots section
    activeSection = 'chatbots';
    document.getElementById('chatgpt-interface')?.scrollIntoView({ behavior: 'smooth' });
  } */

</script>

<!-- Navbar -->
<header class="bg-gradient-to-r from-[#0f535c] to-[#38a0ac] text-white py-4 px-6 flex flex-col md:flex-row items-center justify-between shadow-lg fixed top-0 w-full z-50">
  <div class="flex items-center space-x-4 w-full md:w-auto">
    <a href="/" class="flex items-center space-x-2">
      <img src={logo} alt="LLM Logo" class="w-10 h-10 sm:w-14 sm:h-14 rounded-full border-4 border-blue-200 transition-transform transform hover:scale-110 duration-300" />
      <h1 class="text-xl sm:text-2xl md:text-3xl font-bold">LLMVerse</h1>
    </a>
  </div>

  <!-- Center Links (Desktop) -->
  <nav class="hidden md:flex flex-grow justify-center space-x-6 mt-4 md:mt-0">
    {#each ['Courses', 'Chatbots', 'Contact'] as link}
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





  
  <!-- Chatbots Section -->
  <section id="chatgpt-interface" class="py-16 bg-gray-100" class:hidden={activeSection !== 'chatbots'}>
    <div class="container mx-auto flex max-w-6xl">
      <!-- Sidebar for Chat History -->
      <aside class="w-1/4 bg-white shadow-lg rounded-lg p-6 mr-8">
        <h3 class="text-xl font-bold text-gray-900 mb-6">Chat History</h3>
        <div class="overflow-y-auto max-h-[500px]">
          <ul class="space-y-4">
            <!-- Example Chat History Entries -->
            {#each [
              { date: '2024-09-01', topic: 'Customer Support' },
              { date: '2024-08-15', topic: 'Learning Assistance' }
            ] as { date, topic }}
              <li>
                <button class="w-full text-left p-2 bg-gray-200 rounded-lg hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-[#E1AD01]" onclick={() => loadChat(date, topic)}>
                  <div class="font-semibold text-gray-900">{topic}</div>
                  <div class="text-sm text-gray-600">{date}</div>
                </button>
              </li>
            {/each}
          </ul>
        </div>
      </aside>
  
      <!-- Main Chat Interface -->
      <div class="w-3/4 bg-white shadow-lg rounded-lg p-6 flex flex-col h-[500px]">
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
          <input type="text" id="chat-input" class="flex-1 p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E1AD01]" placeholder="Type your message here...">
          <button id="send-btn" class="ml-4 bg-[#E1AD01] text-white py-2 px-4 rounded-lg hover:bg-[#D1A300] transition-colors duration-300">
            Send
          </button>
        </div>
      </div>
    </div>
  </section>

  <!-- Contact Section -->
  <section id="contact" class="py-16 bg-gray-50" class:hidden={activeSection !== 'contact'}>
    <div class="container mx-auto text-center">
      <h2 class="text-4xl font-extrabold text-[#0f535c] mb-8">Get in Touch</h2>
      <p class="text-gray-600 mb-12 text-lg max-w-2xl mx-auto">If you have any questions or need assistance, feel free to reach out to us!</p>
      <form class="max-w-2xl mx-auto">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
          <div>
            <label for="name" class="block text-left font-semibold mb-2">Name</label>
            <input type="text" id="name" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Your Name">
          </div>
          <div>
            <label for="email" class="block text-left font-semibold mb-2">Email</label>
            <input type="email" id="email" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Your Email">
          </div>
        </div>
        <div>
          <label for="message" class="block text-left font-semibold mb-2">Message</label>
          <textarea id="message" rows="4" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Your Message"></textarea>
        </div>
        <button type="submit" class="mt-6 bg-[#0f535c] text-white py-2 px-6 rounded-lg hover:bg-[#023e8a] transition-colors duration-300">
          Send Message
        </button>
      </form>
    </div>
  </section>


<!-- Footer -->
<footer class="bg-[#023e8a] text-white py-6 text-center">
  <div class="container mx-auto">
    <p>&copy; 2024 LLMVerse. All rights reserved.</p>
  </div>
</footer>
