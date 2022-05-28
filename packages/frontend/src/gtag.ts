import { useLocation } from "react-use";

declare var gtag : any

export const getGtag : any | null = () => {
  return gtag ?? null;
}

export const setPageView = () => {
  const gtag = getGtag()
  if (!gtag) return

  gtag('event', 'page_view', {
    page_title: document.title,
    page_location: document.location.href,
    page_path: document.location.pathname,
  })
}