<script setup>
import { computed, onMounted, ref } from 'vue';
import format from 'date-fns/format';
import parseISO from 'date-fns/parseISO';
import BarChart from 'shared/components/charts/BarChart.vue';

const props = defineProps({
  componentData: { type: Object, default: () => ({}) },
});

// CUSTOM-I18N-HOOK: translated labels come from the ERB; fall back to upstream English
const label = (key, fallback) => props.componentData.labels?.[key] ?? fallback;

const stats = ref(null);
const failed = ref(false);

const loading = computed(() => !stats.value && !failed.value);

onMounted(async () => {
  try {
    const response = await fetch(window.location.pathname, {
      headers: { Accept: 'application/json' },
    });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    stats.value = await response.json();
  } catch {
    failed.value = true;
  }
});

const metrics = computed(() => [
  { label: label('accounts', 'Accounts'), value: stats.value?.accountsCount },
  { label: label('users', 'Users'), value: stats.value?.usersCount },
  { label: label('inboxes', 'Inboxes'), value: stats.value?.inboxesCount },
  {
    label: label('conversations', 'Conversations'),
    value: stats.value?.conversationsCount,
  },
]);

const chartAriaLabel = label(
  'chart_aria_label',
  'Conversations created by day'
);
const chartDateFormat = label('chart_date_format', 'dd-MMM');

const chartData = computed(() => {
  const sourceData = stats.value?.chartData || [];
  return {
    categories: sourceData.map(([day]) =>
      format(parseISO(day), chartDateFormat)
    ),
    series: [
      {
        id: 'conversations',
        label: label('conversations', 'Conversations'),
        color: '#1f93ff',
        data: sourceData.map(([, value]) => value),
      },
    ],
  };
});
</script>

<template>
  <div class="w-full h-full">
    <header class="main-content__header" role="banner">
      <h1 id="page-title" class="main-content__page-title">
        {{ label('title', 'Admin Dashboard') }}
      </h1>
    </header>

    <section class="main-content__body main-content__body--flush">
      <div class="report--list">
        <div v-for="item in metrics" :key="item.label" class="report-card">
          <div class="metric">
            <span
              v-if="loading"
              class="inline-block w-20 h-8 rounded bg-woot-100 animate-pulse"
            />
            <template v-else>
              {{ item.value || label('not_available', 'N/A') }}
            </template>
          </div>
          <div>{{ item.label }}</div>
        </div>
      </div>
    </section>
    <div
      v-if="loading"
      class="p-8 mx-8 h-64 rounded bg-woot-100 animate-pulse"
    />
    <div v-else-if="!failed" class="p-8 w-full min-w-0">
      <BarChart
        :data="chartData"
        :height="500"
        timeseries
        :aria-label="chartAriaLabel"
      />
    </div>
  </div>
</template>
