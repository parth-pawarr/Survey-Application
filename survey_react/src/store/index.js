import { create } from 'zustand';

// Auth Store
export const useAuthStore = create((set) => ({
  user: null,
  token: localStorage.getItem('authToken') || null,
  isAuthenticated: !!localStorage.getItem('authToken'),
  isLoading: false,
  error: null,

  setUser: (user) => set({ user }),
  setToken: (token) => {
    localStorage.setItem('authToken', token);
    set({ token, isAuthenticated: true });
  },
  clearAuth: () => {
    localStorage.removeItem('authToken');
    set({ user: null, token: null, isAuthenticated: false });
  },
  setLoading: (isLoading) => set({ isLoading }),
  setError: (error) => set({ error }),
}));

// Survey Form Store
export const useSurveyFormStore = create((set) => ({
  // Phase 1: Household Basic Information
  phase1: {
    representativeFullName: '',
    mobileNumber: '',
    age: '',
    gender: '',
    totalFamilyMembers: '',
    ayushmanCardStatus: '',
    ayushmanCardCount: '',
  },

  // Phase 2: Healthcare Section
  phase2: {
    hasHealthIssues: 'No',
    affectedMembers: [],
  },

  // Phase 3: Education Section
  phase3: {
    hasSchoolChildren: 'No',
    children: [],
  },

  // Phase 4: Employment Section
  phase4: {
    hasEmployedMembers: 'No',
    employedMembers: [],
    unemployedMembers: [],
  },

  // Village Selection
  village: '',

  // Phase tracking
  currentPhase: 1,

  // Actions
  updatePhase1: (data) =>
    set((state) => ({
      phase1: { ...state.phase1, ...data },
    })),

  updatePhase2: (data) =>
    set((state) => ({
      phase2: { ...state.phase2, ...data },
    })),

  addAffectedMember: (member) =>
    set((state) => ({
      phase2: {
        ...state.phase2,
        affectedMembers: [...state.phase2.affectedMembers, member],
      },
    })),

  removeAffectedMember: (index) =>
    set((state) => ({
      phase2: {
        ...state.phase2,
        affectedMembers: state.phase2.affectedMembers.filter(
          (_, i) => i !== index
        ),
      },
    })),

  updatePhase3: (data) =>
    set((state) => ({
      phase3: { ...state.phase3, ...data },
    })),

  addChild: (child) =>
    set((state) => ({
      phase3: {
        ...state.phase3,
        children: [...state.phase3.children, child],
      },
    })),

  removeChild: (index) =>
    set((state) => ({
      phase3: {
        ...state.phase3,
        children: state.phase3.children.filter((_, i) => i !== index),
      },
    })),

  updatePhase4: (data) =>
    set((state) => ({
      phase4: { ...state.phase4, ...data },
    })),

  addEmployedMember: (member) =>
    set((state) => ({
      phase4: {
        ...state.phase4,
        employedMembers: [...state.phase4.employedMembers, member],
      },
    })),

  removeEmployedMember: (index) =>
    set((state) => ({
      phase4: {
        ...state.phase4,
        employedMembers: state.phase4.employedMembers.filter(
          (_, i) => i !== index
        ),
      },
    })),

  addUnemployedMember: (member) =>
    set((state) => ({
      phase4: {
        ...state.phase4,
        unemployedMembers: [...state.phase4.unemployedMembers, member],
      },
    })),

  removeUnemployedMember: (index) =>
    set((state) => ({
      phase4: {
        ...state.phase4,
        unemployedMembers: state.phase4.unemployedMembers.filter(
          (_, i) => i !== index
        ),
      },
    })),

  setVillage: (village) => set({ village }),
  setCurrentPhase: (phase) => set({ currentPhase: phase }),

  // Get complete form data
  getFormData: () => {
    const state = useSurveyFormStore.getState();
    return {
      phase1: state.phase1,
      phase2: state.phase2,
      phase3: state.phase3,
      phase4: state.phase4,
      village: state.village,
    };
  },

  // Reset form
  resetForm: () =>
    set({
      phase1: {
        representativeFullName: '',
        mobileNumber: '',
        age: '',
        gender: '',
        totalFamilyMembers: '',
        ayushmanCardStatus: '',
        ayushmanCardCount: '',
      },
      phase2: {
        hasHealthIssues: 'No',
        affectedMembers: [],
      },
      phase3: {
        hasSchoolChildren: 'No',
        children: [],
      },
      phase4: {
        hasEmployedMembers: 'No',
        employedMembers: [],
        unemployedMembers: [],
      },
      village: '',
      currentPhase: 1,
    }),
}));

// Admin Dashboard Store
export const useAdminStore = create((set) => ({
  stats: null,
  surveys: [],
  analytics: null,
  isLoading: false,
  error: null,

  setStats: (stats) => set({ stats }),
  setSurveys: (surveys) => set({ surveys }),
  setAnalytics: (analytics) => set({ analytics }),
  setLoading: (isLoading) => set({ isLoading }),
  setError: (error) => set({ error }),
}));
