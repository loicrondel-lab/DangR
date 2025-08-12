import { Route } from '@angular/router';

export const appRoutes: Route[] = [
  {
    path: '',
    loadComponent: () => import('./pages/map.page').then(m => m.MapPage),
  },
  {
    path: 'feed',
    loadComponent: () => import('./pages/feed.page').then(m => m.FeedPage),
  },
  {
    path: 'route',
    loadComponent: () => import('./pages/route.page').then(m => m.RoutePage),
  },
  {
    path: 'profile',
    loadComponent: () => import('./pages/profile.page').then(m => m.ProfilePage),
  },
  {
    path: 'report',
    loadComponent: () => import('./pages/report.page').then(m => m.ReportPage),
  },
  { path: '**', redirectTo: '' },
];
